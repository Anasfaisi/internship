# task-4-7-pg

PostgreSQL 18 on Kubernetes, run by [CloudNativePG](https://cloudnative-pg.io/). Three copies of one database, a connection pool in front, backups in S3, metrics in Prometheus, and a network policy that lets only a labeled client connect.

Namespace: `anas-c`. Cluster name: `task-4-7-pg`.

The backup secret is not in this folder. The manifests only name it (`task-4-7-backup`). Keep that secret out of git. This repository is safer as a private repo, because the S3 bucket path is in the YAML.

## Layout

| File | What it creates |
|---|---|
| `task-4-7-pg` | The database: 3 instances, database `app`, owner `app` |
| `task-4-7-backup-patch.yaml` | Patch that turns on S3 backup and WAL upload |
| `task-4-7-scheduled-backup.yaml` | Daily backup at 02:00 |
| `task-4-7-pooler.yaml` | PgBouncer for writes and for reads |
| `task-4-7-client.yaml` | Pod allowed to connect (`role=db-client`) |
| `task-4-7-denied.yaml` | Pod that must be blocked (`role=denied`) |
| `task-4-7-netpol.yaml` | Who may open a connection |
| `task-4-7-monitor.yaml` | Prometheus scrape and three alerts |
| `task-4-7-pitr.yaml` | Practice restore into a second cluster |
| `task-4-7-restore.yaml` | Earlier restore manifest. It was not left running |
| `architecture.md` | Notes on alerts, scrape mistakes, and the network policy |

## How the pieces fit

```text
task-4-7-client  --ok-->  task-4-7-pooler-rw  -->  primary
task-4-7-client  --ok-->  task-4-7-pooler-ro  -->  replica
task-4-7-denied  --blocked by NetworkPolicy-->  anything on port 5432

primary  --WAL files-->  s3://task-4-7-anas-c-pg/task-4-7-pg/task-4-7-pg/wals/
schedule --full copy-->  s3://task-4-7-anas-c-pg/task-4-7-pg/task-4-7-pg/base/

Prometheus (namespace monitoring)  --HTTP :9187-->  each Postgres pod
```

CloudNativePG also creates Services:

| Service | Where it sends the session |
|---|---|
| `task-4-7-pg-rw` | Current primary. Reads and writes |
| `task-4-7-pg-ro` | Replicas only |
| `task-4-7-pg-r` | Any instance |
| `task-4-7-pooler-rw` | PgBouncer, then the primary |
| `task-4-7-pooler-ro` | PgBouncer, then a replica |

`pg_is_in_recovery()` is `f` on the primary and `t` on a replica. `inet_server_addr()` is the pod IP that answered.

Each instance asks for its own node (`topologyKey: kubernetes.io/hostname`). Disk is 5Gi on `civo-volume`. Superuser access from outside the pod is off. Inside the pod, `psql -U postgres` still works over the local socket.

## Backup and WAL

A backup is a full copy of the data files at one moment. WAL is the log of every insert, update, and delete after that copy. Postgres writes the change into a WAL file on the pod first. When that file is closed, `archive_command` uploads it to S3. CloudNativePG fills in `archive_mode` and `archive_command` from `task-4-7-backup-patch.yaml`. Files are gzip-compressed.

The uploaded files live under the cluster name:

```text
s3://task-4-7-anas-c-pg/task-4-7-pg/task-4-7-pg/
```

`serverName` defaults to the cluster name. A restore cluster with a different name looks in the wrong folder unless `serverName: task-4-7-pg` is set.

A WAL file is uploaded only after it is closed. `pg_switch_wal()` closes the open file. One call can land exactly on a file boundary and leave the new file open, so `last_archived_wal` does not move. A second call closes that file.

Point-in-time restore does not rewind the live database. It builds a second cluster from the S3 copy and stops at `targetTime`. That time has to sit in the archived window:

- After the end of a completed backup (`status.firstRecoverabilityPoint` is the earliest).
- Not after the last WAL file that actually reached S3.

If the time is later than the archived log, Postgres stops with `recovery ended before configured recovery target was reached`. If the first WAL file of the chosen backup is missing, the job stops with `WAL not found`. A cluster in that state does not retry. Delete it, then apply the file again.

`task-4-7-pitr.yaml` is that second cluster. Change `targetTime` before applying it. Delete it when the check is done:

```bash
kubectl delete cluster task-4-7-pg-pitr -n anas-c
```

## Apply

The CloudNativePG operator must already be installed. Create the backup secret before the backup patch. The secret keys are `ACCESS_KEY_ID` and `ACCESS_SECRET_KEY`.

```bash
kubectl apply -f task-4-7-pg
kubectl patch cluster task-4-7-pg -n anas-c --type merge --patch-file task-4-7-backup-patch.yaml
kubectl apply -f task-4-7-scheduled-backup.yaml
kubectl apply -f task-4-7-pooler.yaml
kubectl apply -f task-4-7-client.yaml
kubectl apply -f task-4-7-denied.yaml
kubectl apply -f task-4-7-netpol.yaml
kubectl apply -f task-4-7-monitor.yaml
```

The client pod reads `task-4-7-pg-app`, which the operator creates from the cluster. Apply the client after the cluster exists.

## Checks

Write service hits the primary. Read service hits a replica.

```bash
kubectl exec -n anas-c task-4-7-client -c psql -- psql -h task-4-7-pg-rw -c "SELECT pg_is_in_recovery(), inet_server_addr();"
kubectl exec -n anas-c task-4-7-client -c psql -- psql -h task-4-7-pg-ro -c "SELECT pg_is_in_recovery(), inet_server_addr();"
```

Pool path: three sessions through `task-4-7-pooler-rw` show up on the primary with `client_addr` equal to the pooler pod IP. Pool mode is `transaction`, `default_pool_size` is 20, so three clients stay three server sessions.

```bash
kubectl get pooler -n anas-c
kubectl get pod -n anas-c -l cnpg.io/poolerName=task-4-7-pooler-rw -o wide
```

Backups:

```bash
kubectl get backup,scheduledbackup -n anas-c
kubectl get cluster task-4-7-pg -n anas-c -o jsonpath='{.status.firstRecoverabilityPoint}{"\n"}{.status.lastSuccessfulBackup}{"\n"}'
```

Failover: delete the current primary pod. The operator promotes a replica. Writes through `task-4-7-pg-rw` continue. The Service follows the new primary.

```bash
kubectl get cluster task-4-7-pg -n anas-c -o jsonpath='{.status.currentPrimary}'
```

Blocked client: `task-4-7-denied` has the same password and the label `role=denied`. The policy allows port 5432 only from `role=db-client`, from the database pods themselves, and from `cnpg-system`.

```bash
kubectl exec -n anas-c task-4-7-denied -c psql -- env PGCONNECT_TIMEOUT=5 psql -h task-4-7-pg-rw -c "SELECT 1;"
```

That command times out or is refused. The same command from `task-4-7-client` returns `1`.

Metrics: Grafana is `svc/prometheus-stack-grafana` in namespace `monitoring`, port 80. The PodMonitor must be labeled `release=prometheus-stack` and must scrape HTTP. Setting `scheme: https` marks the targets down.

```bash
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
```

Open `http://localhost:3000`. The login is in secret `prometheus-stack-grafana`.

## Alerts

| Alert | Fires when |
|---|---|
| `Task47ReplicationLag` | Replication lag over 30 seconds for 2 minutes |
| `Task47DiskFilling` | Less than 20% free on a `task-4-7-pg-*` volume for 10 minutes |
| `Task47BackupStale` | No backup timestamp, or the last success is older than 24 hours, for 5 minutes |

`Task47BackupStale` also fires when Prometheus cannot scrape port 9187. A completed Backup object does not clear it until the scrape works. Details are in `architecture.md`.

## Recovery job logs

`Cluster is unrecoverable` is the status line. The reason is in the restore job:

```bash
kubectl describe cluster task-4-7-pg-pitr -n anas-c
kubectl logs -n anas-c job/task-4-7-pg-pitr-1-full-recovery -c full-recovery --tail=80
```
