# Lab 2 — Tougher

Time: 5 hours.

Use the `hack-eks` cluster from lab 1. If that cluster is gone, run lab 1 section 1 again first.

This lab adds a Helmfile platform, TLS, a chart you write, Postgres, and one Grafana panel. Skip S3 backup and point-in-time restore. Those stay in `task-4-7-pg`.

Namespace stays `hackathon`. If lab 1 left a `ResourceQuota`, delete it before this lab. Prometheus and CloudNativePG need more than that quota.

## 1. Platform with Helmfile

New file: `kubernetes-tasks/eks-mini-hackathon/hack-helmfile.yaml`. You write the values. Pin a chart version on every release.

Install, in this order, all from that one file:

| Release | Chart | Namespace |
|---|---|---|
| `hack-ingress` | `ingress-nginx` | `hackathon` |
| `cert-manager` | `jetstack/cert-manager` | `cert-manager` |
| `hack-cnpg` | `cnpg/cloudnative-pg` | `cnpg-system` |
| `hack-mon` | `prometheus-community/kube-prometheus-stack` | `monitoring` |

`helmfile apply` must be the only install command. If lab 1 already installed ingress-nginx by hand, adopt it into this Helmfile or uninstall it first so you do not run two controllers.

Ingress controller:

- Same class name as lab 1 if you keep that Ingress: `hack-nginx`
- Scoped to namespace `hackathon`
- Service type `LoadBalancer`

cert-manager:

- `crds.enabled=true` (or install CRDs the way that chart version documents)
- Wait until the webhook pod is `Ready` before the next release. Helmfile `needs` is the right tool.

kube-prometheus-stack:

- Grafana service type `ClusterIP` (you will put Ingress in front of it)
- Prometheus retention `6h` so the disk stays small
- Set Grafana and Prometheus resource requests. If the nodes run out of memory, lower the requests and say what you changed. Do not leave requests empty.

CloudNativePG operator only in this step. The database comes later.

## 2. TLS

Do not use the Cloudflare token from `task-2-51` unless you want the stretch goal.

Required:

- A `ClusterIssuer` named `hack-selfsigned` that uses the `selfSigned` issuer
- A `Certificate` named `shop-tls` in `hackathon`
- DNS name `shop.hack.local`
- Secret name `shop-tls`

`shop.hack.local` will not resolve on the public internet. That is fine. You will curl the load balancer with `--resolve`.

Stretch, only after the checklist is green: a second `ClusterIssuer` with Let's Encrypt DNS-01, and a real hostname. The required path stays the self-signed issuer.

## 3. Your chart

Folder: `kubernetes-tasks/eks-mini-hackathon/shop-chart/`.

`helm create` is allowed. Then change it until `helm template` matches this:

- Chart name `shop`
- Deployment `shop`, 2 replicas, image `nginxinc/nginx-unprivileged:1.27`, container port `8080`
- `values.yaml` holds the image, replica count, resource requests and limits, and the ingress host
- Requests at least `50m` CPU and `64Mi` memory. Limits must be higher than the requests.
- HTTP `startupProbe`, `readinessProbe`, and `livenessProbe` on port `8080` path `/`
- `securityContext.runAsNonRoot: true` (this image already listens as a non-root user)
- ConfigMap rendered from values, mounted as `/usr/share/nginx/html/index.html`, body exactly `shop-ok`
- Service `ClusterIP` port `80` to `8080`
- Ingress class `hack-nginx`, host `shop.hack.local`, path `/`, TLS secret `shop-tls`
- Ingress annotation `cert-manager.io/cluster-issuer: hack-selfsigned` is optional if you already applied the Certificate yourself. One of the two must create `shop-tls`.

Install with Helm, release name `shop`, namespace `hackathon`.

Check:

```bash
curl -sk --resolve shop.hack.local:443:<LOAD_BALANCER_IP> https://shop.hack.local/
```

Body must be `shop-ok`. `kubectl -n hackathon get certificate shop-tls` must be `Ready=True`.

## 4. Database

A CloudNativePG `Cluster` in `hackathon`:

- Name `shop-pg`
- 2 instances (not 3)
- Postgres 17 or 18, image the operator accepts
- Database `shop`, owner `shop`
- Each instance: `1Gi` storage, request `100m` CPU and `256Mi` memory, limit `500m` CPU and `512Mi` memory
- `podAntiAffinity` so the two instances prefer different nodes (`kubernetes.io/hostname`). On a 2-node group this should place one pod per node. If one stays pending, read the event and either relax the rule to preferred or add the third node. Write down which you chose.

`Shop` does not have to query Postgres. A client pod does.

`NetworkPolicy` `shop-pg-ingress` in `hackathon`:

- Applies to pods of this Cluster (use the labels CloudNativePG puts on the instance pods; read them with `kubectl get pod --show-labels`)
- Allow TCP `5432` only from pods with label `role=shop-client`
- Allow the operator and Prometheus to scrape. If metrics or failover break, you blocked the operator. Fix the policy. Port `8000` is the operator. Port `9187` is the exporter.

Client, file `shop-client.yaml`:

- Pod name `shop-client`, label `role=shop-client`
- Image that contains `psql` (the CloudNativePG postgres image is fine)
- Command: create table `items(id int primary key, name text)` if missing, insert one row `1, 'hammer'`, then sleep
- Connect through the `-rw` Service CloudNativePG creates, user `shop`, database `shop`
- Read the password from the Secret the operator created. Mount that Secret. Do not put the password in the YAML.

Denied pod `shop-denied`, label `role=denied`, same image, `psql` to the same Service. It must fail to connect.

Show both:

```bash
kubectl -n hackathon exec shop-client -- psql -U shop -d shop -c 'select * from items;'
kubectl -n hackathon exec shop-denied -- psql -U shop -d shop -h shop-pg-rw -c 'select 1'
```

First command prints `hammer`. Second command times out or is refused.

## 5. One Grafana check

Ingress for Grafana in namespace `monitoring` or `hackathon`:

- Host `grafana.hack.local`
- Class `hack-nginx`
- TLS with the same self-signed issuer, secret `grafana-tls`

Open Grafana with `curl -sk` or a browser hosts entry. Default user is in the `hack-mon` Grafana Secret. Find it. Do not reset the password by redeploying with a password you commit.

In Grafana Explore, run one PromQL query and save a dashboard named `hackathon` with that panel:

```promql
count(kube_pod_status_ready{namespace="hackathon", condition="true"})
```

The number must be at least the shop pods plus the two Postgres pods plus the client (the denied pod may be crash-looping; that is allowed).

Add one `PrometheusRule` in `hackathon`:

- Name `shop-down`
- Alert when `kube_deployment_status_replicas_available{namespace="hackathon", deployment="shop"} < 2` for 2 minutes
- Severity label `warning`

Force it: scale `shop` to `0`, wait, and show the alert `Pending` or `Firing` in Prometheus or Grafana. Scale back to `2` before you finish.

## Checklist

- [ ] `helmfile apply` is green and a second run changes nothing
- [ ] `shop-tls` and `grafana-tls` are `Ready`
- [ ] `curl` to `shop.hack.local` returns `shop-ok`
- [ ] `shop-pg` has 2 ready instances
- [ ] `shop-client` can read `hammer`, `shop-denied` cannot connect
- [ ] Dashboard `hackathon` shows the ready-pod count
- [ ] `shop-down` entered `Pending` or `Firing` while replicas were 0, and shop is back at 2
- [ ] No password, Cloudflare token, or AWS key is in the files you would commit

## Destroy

From `terraform/hack-eks`:

```bash
helmfile -f kubernetes-tasks/eks-mini-hackathon/hack-helmfile.yaml destroy
kubectl delete ns hackathon monitoring cnpg-system cert-manager
terraform destroy
```

Load balancers and volumes sometimes outlive the cluster. After destroy, check the AWS console for a leftover ELB or EBS volume in `us-east-1` and delete it.
