# PromQL

**Chosen focus:** Namespace resource summary. Same page as `task-2-54-logql.md`.

One namespace. `$namespace` is on every query. CPU, memory, running pods, restarts. Error logs stay in Loki, not here.

Workload health is the same signals for one deployment. This page is the whole namespace, so there is no deployment filter.

Cluster capacity is node pressure across the cluster. It is not on this page.

## Total Running Pods

```promql
count(kube_pod_status_phase{namespace="$namespace", phase="Running"} == 1)
```

Pods in phase Running. `== 1` keeps the live series. `count` is the pod count. Unit: short.

## CPU Usage

```promql
sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="$namespace", container!="", container!="POD"}[5m]))
```

Cores per pod, averaged over 5 minutes. `container!=""` and `container!="POD"` drop the empty series and the pause container. Unit: cores. Yellow at 0.5, red at 1.

## Memory Usage

```promql
sum by (pod) (container_memory_working_set_bytes{namespace="$namespace", container!="", container!="POD"})
```

Working set per pod. Unit: bytes.

```promql
0.9 * sum by (pod) (kube_pod_container_resource_limits{namespace="$namespace", resource="memory", unit="byte"})
```

Dashed line. 90% of that pod's memory limit. A pod with no limit has no line.

## Pod Restart Count

```promql
sum by (pod) (increase(kube_pod_container_status_restarts_total{namespace="$namespace"}[1h]))
```

Restarts in the last hour, per pod. A step up is a crash loop. Yellow at 1, red at 5.
