## Custom Dashboard Focus: Namespace Resource Summary

**Chosen Focus:** Namespace Resource Summary

**Rationale:**

The objective is to create a unified dashboard for monitoring a specific Kubernetes namespace. It will display CPU and memory utilization, pod count, container restart count, and application logs.

Existing pre-built dashboards provide general cluster and infrastructure monitoring, but this custom dashboard will provide a namespace-specific operational view by combining Prometheus metrics and Loki logs.

## Panel 1 - Total Running Pods 

Data source: Prometheus. Visualization: Stat. Unit: short. Calculation: Last (not null).

```promql
sum(kube_pod_status_phase{namespace="$namespace", phase="Running"} == 1)
```

Pods currently running in the selected namespace. `== 1` keeps the live series. `sum` counts them.



## Panel 2 - CPU Usage by Pod

Data source: Prometheus. Visualization: Time series. Unit: cores. Legend: `{{pod}}`.

```promql
sum by (pod) (
  rate(
    container_cpu_usage_seconds_total{
      namespace="$namespace",
      container!="",
      container!="POD"
    }[5m]
  )
)
```

Cores per pod. `rate()` turns the CPU-time counter into cores. Empty series and the pause container `POD` are dropped.

## Panel 3 - Memory Usage by Pod

Data source: Prometheus. Visualization: Time series. Unit: bytes (IEC). Legend: `{{pod}}`.

```promql
sum by (pod) (
  container_memory_working_set_bytes{
    namespace="$namespace",
    container!="",
    container!="POD"
  }
)
```

Working set per pod. This is a gauge, so no `rate()`.


## Panel 4 - Pod Restarts — Last 1 Hour

Data source: Prometheus. Visualization: Time series. Unit: short. Legend: `{{pod}}`.

```promql
4
```

Restarts over the previous hour, per pod. `increase()` estimates the counter rise and can be fractional. Yellow at 1, red at 5.

## Panel 5 — Error Logs

Type: Logs. Data source: Loki.

```logql
{namespace="$namespace"} |~ "(?i)error"
```

Error log lines from the selected namespace. `(?i)` matches `error` in any case.

`<h3>` Part 1 `<h3>`
---
## All logs from the monitoring namespace

```logql
{namespace="monitoring"}
```

Stream selector only. Loki returns every log line labeled `namespace="monitoring"`, with no text filter. Prometheus, Grafana, and the rest of the metrics stack run in that namespace, so this is the first query when scrapes, alerts, or dashboards fail and the broken pod is still unknown. The sample shows the use: Prometheus logs `level=ERROR` and `no space left on device` while writing its WAL. One query surfaces that disk-full failure across the namespace.

```text
2026-11-20 11:32:11.241
time=2026-11-20T06:02:11.241Z level=ERROR source=scrape.go:1418 msg="Scrape commit failed" component="scrape manager" scrape_pool=serviceMonitor/anas-c/task-2-51-anas-prom-kubelet/1 target=https://192.168.1.32:10250/metrics/cadvisor err="write to WAL: log samples: write /prometheus/wal/00000486: no space left on device"

2026-11-20 11:32:11.043
time=2026-11-20T06:02:11.043Z level=ERROR source=scrape.go:1418 msg="Scrape commit failed" component="scrape manager" scrape_pool=serviceMonitor/anas-c/task-2-51-anas-prom-kubelet/1 target=https://192.168.1.30:10250/metrics/cadvisor err="write to WAL: log samples: write /prometheus/wal/00000486: no space left on device"
```



## Logs from one Grafana pod

```logql
{namespace="monitoring", pod="prometheus-stack-grafana-76b45766c-24cbp"} |= ``
```

This asks Loki for logs from one pod only. The long name is one running copy of Grafana. `namespace="monitoring"` keeps the search inside the monitoring namespace. `|= `` ` means "do not drop any line", so every log from that pod stays.

Use this when Grafana itself looks wrong: Explore is slow, a panel fails, or you want to see the question Grafana sent to Loki. The first query shows the whole namespace, so Prometheus errors sit next to Grafana lines. This query hides that noise.

What to read on each line:

- `level` — `info` is normal. `warn` or `error` means something failed.
- `msg` — what Grafana just did. Here it got a reply, then read that reply.
- `statusCode` and `status` — `200` and `ok` mean Loki answered fine.
- `duration` — how long that step took. Here Loki took about 20ms. Reading the reply took less than 1ms.
- `uname` — who ran the query. Here it is `admin`.
- `fromAlert` — `false` means a person in the UI. `true` means an alert rule.
- `query` — the exact LogQL Grafana sent. Here it is this same query.
- `queryType` — `range` means a time window, not one single moment.
- `lokiHost` — which Loki Grafana called. Here `loki-stack.monitoring.svc.cluster.local:3100`.
- `framesLength` — how many result tables came back. Here `1`.
- `dsName` — which Grafana data source was used. Here `Loki`.

```text
2026-11-20 11:41:37.703
logger=tsdb.loki endpoint=queryData pluginId=loki dsName=Loki dsUID=loki uname=admin fromAlert=false t=2026-11-20T06:11:37.703894057Z level=info msg="Response parsed from loki" duration=324.239µs framesLength=1 stage=parseResponse

2026-11-20 11:41:37.703
logger=tsdb.loki endpoint=queryData pluginId=loki dsName=Loki dsUID=loki uname=admin fromAlert=false t=2026-11-20T06:11:37.703525584Z level=info msg="Response received from loki" duration=19.513933ms stage=databaseRequest statusCode=200 contentLength= start=2026-11-20T05:11:29.279Z end=2026-11-20T06:11:29.279Z step=1h0m0s query="{namespace=\"monitoring\", pod=\"prometheus-stack-grafana-76b45766c-24cbp\"} |= ``" queryType=range direction=backward maxLines=10 supportingQueryType=dataSample lokiHost=loki-stack.monitoring.svc.cluster.local:3100 lokiPath=/loki/api/v1/query_range status=ok
```

This sample is a healthy call. `admin` ran the query, Loki answered `200` / `ok` in about 20ms, and Grafana parsed one frame. No error on these lines.




## Filter expressions

```logql
{ namespace=~".+", pod="prometheus-stack-grafana-76b45766c-24cbp"} |= `error`
```

Two different filters are in this line.

The part `=~` means the label must match a pattern. `.+` means "one or more characters", so `namespace=~".+"` means "namespace is not empty". Writing 

The part after `{}` picks lines by text:

- `|= `error`` — keep lines that contain `error`
- `!= `error`` — drop lines that contain `error`
- `|~ `error|ERROR`` — keep lines that match a pattern
- `!~ `error`` — drop lines that match a pattern

`|= `` ` from the last query was an empty text filter, so nothing was dropped. `|= `error`` keeps only lines with that word.

```text
2026-11-20 11:51:26.889
logger=context userId=1 orgId=1 uname=admin t=2026-11-20T06:21:26.889873351Z level=info msg="Request Completed" method=POST path=/api/ds/query status=400 remote_addr=127.0.0.1 time_ms=11 duration=11.357231ms size=161 referer="http://localhost:3001/explore?orgId=1&panes=%7B%22wd2%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bnamespace%3D~%5C%22.%2B%5C%22%2C%7D+%7C%3D+%60error%60%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22code%22%2C%22direction%22%3A%22backward%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&schemaVersion=1" handler=/api/ds/query status_source=downstream
```

This line is Grafana's HTTP log (`logger=context`), not the Loki plugin log from the last sample. New fields:

- `method=POST` — Explore sends the query as a POST.
- `path` and `handler` — both `/api/ds/query`, the API Explore uses to run a query.
- `status=400` — the query was rejected. Last sample was `200`. A 400 means the query text is invalid, not that the app crashed.
- `status_source=downstream` — Loki rejected it. Grafana only passed that error on.
- `remote_addr=127.0.0.1` — the click came through the port-forward on this machine.
- `size=161` — the answer was 161 bytes, a short error, not a page of logs.
- `orgId=1` — the default Grafana org.
- `referer` — the Explore page URL. The real query is hidden in it, URL-encoded. Decoded, it is `{namespace=~".+",} |= `error``. The comma before `}` is not valid. That comma is why this line is `400`.

`time_ms=11` is the same timing as `duration`, rounded to milliseconds.

Correct forms. No comma before `}`. One matcher per label. `.+` only goes with `=~` or `!~`.

```logql
{namespace=~".+"} |= `error`
```

Every namespace, only lines that contain `error`. Loki will not run `{}` with no label, so `{namespace=~".+"}` is the usual way to say "all streams".

```logql
{namespace="monitoring", pod="prometheus-stack-grafana-76b45766c-24cbp"} |= `error`
```

One known pod. Use `=` here. The name is already exact, so `.+` is not needed.

```logql
{namespace="monitoring", pod=~"prometheus-stack-grafana-.+"} |= `error`
```

Every Grafana pod in that namespace. `prometheus-stack-grafana-.+` means "starts with `prometheus-stack-grafana-`, then one or more characters" (the replica hash).

How `.+` works. It is a pattern, not a word.

- `.` means any one character.
- `+` means one or more of the thing just before it.
- `.+` means one or more of any character. The label must have some text. An empty label does not match.
- `.*` means zero or more. It also matches an empty label, so `.+` is the one to use when you want "anything that is set".

`=~` is "label matches this pattern". `|~` is "the log line matches this pattern". Same `.+` idea, different place.


## Two filters on one query

Typed in Explore:

```logql
{namespace=~"monitoring", pod="prometheus-stack-grafana-76b45766c-24cbp"} |= "error" != "404"
```

`|= "error" != "404"` is valid. Filters run left to right. First keep lines that contain `error`. Then drop lines that also contain `404`. A line that says `error` and `404` is removed. A line that says `error` and not `404` stays. `!=` here is outside `{}`, so it checks the text of the line, not a label.

`namespace=~"monitoring"` is the weak part. `=~` is a pattern, and this pattern is not tied to the start or the end. It matches any namespace that contains the letters `monitoring`, including `kube-monitoring`. The exact namespace is written with `=`:

```logql
{namespace="monitoring", pod="prometheus-stack-grafana-76b45766c-24cbp"} |= "error" != "404"
```

`"error"` and `` `error` `` mean the same thing. Use backticks when the text itself has quotes.

What Loki actually ran (from the log below) is a different query, and it succeeded:

```logql
{namespace=~".+", pod="prometheus-stack-grafana-76b45766c-24cbp", stream!="stdout"} |= "error"
```

```text
2026-11-20 12:02:56.348
logger=tsdb.loki endpoint=queryData pluginId=loki dsName=Loki dsUID=loki uname=admin fromAlert=false t=2026-11-20T06:32:56.348379079Z level=info msg="Response received from loki" duration=30.245821ms stage=databaseRequest statusCode=200 contentLength= start=2026-11-20T05:32:55.738Z end=2026-11-20T06:32:55.738Z step=5s query="{namespace=~\".+\", pod=\"prometheus-stack-grafana-76b45766c-24cbp\", stream!=\"stdout\"} |= \"error\"\r\n\r\n" queryType=range direction=backward maxLines=1000 supportingQueryType=none lokiHost=loki-stack.monitoring.svc.cluster.local:3100 lokiPath=/loki/api/v1/query_range status=ok
```

`statusCode=200` and `status=ok`. This query was accepted. New fields:

- `step=5s` — width of each time bucket Grafana asked for. The earlier call used `1h`.
- `maxLines=1000` — stop after 1000 lines. The small sample query earlier used `10`.
- `direction=backward` — newest lines first.
- `supportingQueryType=none` — this is the main query. The earlier line was `dataSample`, the tiny preview query.
- `\r\n\r\n` at the end of `query` — two blank lines were left in the box. Loki ignored them.

## Log line rate (lines per second) per namespace

```logql
sum(rate({namespace=~".+"}[5m])) by (namespace)
```

This query does not print log lines. It does not measure CPU or memory either. It counts log lines and Grafana draws that count as a graph.

CPU and memory use the same words (`rate`, `sum`, `by`) but a different thing inside. CPU counts a metric such as `container_cpu_usage_seconds_total`. Memory reads a metric such as `container_memory_working_set_bytes`. Those live in Prometheus. This query has `{namespace=~".+"}` inside, which is a Loki log selector, so the number is log lines.

- `{namespace=~".+"}` — every stream that has a namespace.
- `[5m]` — look at the last 5 minutes of those lines.
- `rate(...[5m])` — how many lines per second, averaged over those 5 minutes.
- `sum(...) by (namespace)` — add the pod and container rates together, and keep one number per namespace.
-no of log lines per second (the calculation)

Read the graph for a namespace that is much higher than the others, or one that jumps. Then open that namespace with `{namespace="that-name"}` and read the lines. A steady high rate fills Loki disk. A sudden jump means something just started logging hard.

The line below is not the result of this query. It is the same Prometheus disk error as the first sample: the WAL file cannot be written because the disk is full. This rate query counts Loki log lines. It does not measure the Prometheus WAL disk.

```text
2026-11-20 15:19:12.853
time=2026-11-20T09:49:12.852Z level=ERROR source=scrape.go:1418 msg="Scrape commit failed" component="scrape manager" scrape_pool=serviceMonitor/anas-c/task-2-51-anas-prom-kubelet/0 target=https://192.168.1.33:10250/metrics err="write to WAL: log samples: write /prometheus/wal/00000486: no space left on device"
```

## Parsed fields

```logql
{namespace="monitoring"} | json | level=~"error|warn"
```

`| json` reads the log line as JSON and turns each key into a field. `{"level":"error","msg":"disk full"}` becomes a field named `level`. The filter `level=~"error|warn"` then keeps only lines whose `level` is `error` or `warn`.

Checked this against Loki for the `monitoring` namespace. The query returns no lines.

Two reasons:

- Most lines are not JSON. Prometheus and Grafana print `key=value` text, like the WAL line above (`level=ERROR msg="Scrape commit failed"`). `| json` cannot read that shape. It sets `__error__=JSONParserErr` and does not create a `level` field, so the filter drops the line.
- The one container that does print JSON is the Grafana dashboard sidecar (`grafana-sc-dashboard`). A real line looks like `{"time":"...","level":"INFO","msg":"Writing /tmp/dashboards/workload-total.json (ascii)"}`. Over the last 6 hours every parsed `level` on those lines was `INFO`. None were `error` or `warn`, and the pattern is lowercase, so `INFO` would not match anyway.

Use `| json` only when the line itself is one JSON object. Then filter the field you care about:

```logql
{namespace="monitoring"} | json | level=~"ERROR|WARN|error|warn"
```

For the `key=value` lines in this namespace, the parser that works is `| logfmt`. Over the last 30 minutes that found about 25809 `ERROR` lines and 9860 `WARN` lines:

```logql
{namespace="monitoring"} | logfmt | level=~"ERROR|WARN|error|warn"
```


## Question 
* The difference between a stream selector and a filter expression
A stream selector is the {namespace="monitoring"} part. It picks which log streams to open, using labels Loki has already indexed. A filter is the |= "error" or | json part. It runs after that, and reads the text of each line. The selector chooses the streams. The filter searches inside them.

* Why Loki only indexes labels and not log content, and what trade-off this creates

Loki indexes only labels, such as namespace and pod, not the words inside the line. Labels are few and known. The log text is huge, so indexing every word would make writes slow and the index enormous.


---
