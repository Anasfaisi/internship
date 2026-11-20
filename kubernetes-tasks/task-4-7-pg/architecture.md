That manifest is not applied. A second database would add more pods on a cluster that is already shared and short on memory.

What is monitored and what triggers an alert
PodMonitor/task-4-7-pg selects pods labeled cnpg.io/cluster=task-4-7-pg and reads the port named metrics (9187) every 30 seconds. The label release: prometheus-stack is required. The Prometheus in monitoring (prometheus-stack-kube-prom-prometheus) ignores monitors without it. It watches every namespace, so the monitor can live in anas-c and we do not create objects in monitoring.

The metrics port speaks HTTP. A PodMonitor set to https makes every target DOWN with server gave HTTP response to HTTPS client. The endpoint block must not set scheme: https. We saw that error on pods task-4-7-pg-1, task-4-7-pg-2, and task-4-7-pg-3.

PrometheusRule/task-4-7-pg defines three alerts.

Alert	Fires when	What we do
Task47ReplicationLag	cnpg_pg_replication_lag for this namespace is above 30 seconds for 2 minutes	Look at that replica's disk and log. Reads on -ro may be stale. Do not fail over only because of lag.
Task47DiskFilling	Free space on a task-4-7-pg-* volume is under 20% for 10 minutes	Find what grew, and expand the disk before it hits 100%. PostgreSQL stops when the disk is full.
Task47BackupStale	The series cnpg_collector_last_available_backup_timestamp is missing, or the timestamp is older than 24 hours, for 5 minutes	Confirm a Backup is completed, then confirm the Prometheus targets for this PodMonitor are UP.

Task47BackupStale turned red while task-4-7-pg-daily-20261118211419 was already completed. The value on the alert was 1, which is absent() reporting that the metric was not scraped. It had been firing since the rule was created, which is longer than the backup has existed. The daily schedule was not the cause. Fixing the scrape to HTTP is what lets the timestamp from today's backup clear the alert. Starting another backup does not, if Prometheus still cannot read port 9187.

The same Prometheus UI is at port 9090 of Service prometheus-stack-kube-prom-prometheus. kubectl port-forward only opens that page on a laptop. It does not change the service. The rules named task-2-51-anas-prom-* are older work in the same namespace. They were not modified.

Who can connect
NetworkPolicy/task-4-7-pg-allow selects only pods labeled cnpg.io/cluster=task-4-7-pg. Older pods in anas-c are outside it. The policy sets Ingress only, so outbound calls stay open. That is why the primary can reach s3.us-east-1.amazonaws.com without a second rule.

Incoming traffic is allowed from:

Pods of this same database, on port 5432, so a replica can receive the live copy and PgBouncer can reach PostgreSQL.
Namespace cnpg-system, on 5432 and 8000, so the operator can check health and run the failover we watched.
Pods labeled role=db-client, on 5432. That label is on task-4-7-client.
Namespace monitoring, on 9187, so Prometheus can scrape.
With the policy present, task-4-7-client still receives a row from SELECT 1 through the write pooler. task-4-7-denied has the same password and the label role=denied. Its connection to task-4-7-pg-rw is refused. The label does nothing by itself. After the policy object was deleted, the same denied pod received a row. Creating the policy again is what blocks it.

Database pods also call each other on port 8000. The policy allows that port only from cnpg-system, so those peer checks are refused. The pods stay Ready because the local process can still see the Kubernetes API. WAL upload does not use port 8000. It is an outbound connection to S3.
