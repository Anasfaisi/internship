# Focus

**Chosen focus:** Namespace resource summary.

One dashboard for one namespace. It shows CPU and memory usage, how many pods are running, which pods are restarting, and the error logs for that namespace.

**Rationale:**

This page answers one question: is this namespace healthy, and what is it using?

Workload health uses the same signals (CPU, memory, restarts, logs) but only for one deployment. The namespace page is the wider cut, so a deployment filter is not part of this design.

Cluster capacity is node pressure, free room to schedule, and top consumers across the whole cluster. Those numbers sit outside one namespace. The stock cluster dashboard already shows them. This design does not add a cluster panel.

CPU and memory, summed for the selected namespace, are the namespace totals. That is the "whole namespace" view. It does not need an extra panel.

## Part 3 — plan

One variable, `$namespace`. Every panel uses it.

| Panel | What it shows |
|---|---|
| 1. Stat | Running pods in `$namespace`. This is the pod count. |
| 2. Time series | CPU usage, summed for `$namespace`. |
| 3. Time series | Memory usage, summed for `$namespace`. |
| 4. Time series | Restart count. A line that steps up is the crash loop. |
| 5. Logs | Error logs for `$namespace`. |

## Part 4 — dashboard

Grafana dashboard `task-2-54-dashboard`. The JSON is `task-2-54-dashboard.json`. Variable `namespace` is `label_values(kube_pod_info, namespace)`.

| Panel | Query |
|---|---|
| Total Running Pods | `count(kube_pod_status_phase{namespace="$namespace", phase="Running"} == 1)` |
| CPU Usage | `sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="$namespace", container!="", container!="POD"}[5m]))` |
| Memory Usage | `sum by (pod) (container_memory_working_set_bytes{namespace="$namespace", container!="", container!="POD"})` |
| 90% of memory limit | `0.9 * sum by (pod) (kube_pod_container_resource_limits{namespace="$namespace", resource="memory", unit="byte"})` |
| Pod Restart Count | `sum by (pod) (increase(kube_pod_container_status_restarts_total{namespace="$namespace"}[1h]))` |
| Error Logs | `{namespace="$namespace"} \|~ "(?i)error"` |

Rows: Stats, then Usage, then Logs. CPU is yellow at 0.5 core and red at 1. Restarts are yellow at 1 and red at 5. Memory stays in bytes. The dashed line is 90% of the limit, per pod. One shared byte threshold cannot be 90% of every pod's limit, because each pod has its own limit.



image.png