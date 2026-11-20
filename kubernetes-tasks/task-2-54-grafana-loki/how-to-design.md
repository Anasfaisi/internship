# How to plan a query when there is no AI

Design here means deciding the question, where the facts come from, and what the query is allowed to claim. The query text comes last. If you start by typing LogQL, you will document a guess.

This is the same loop for a dashboard, an alert, or a log query. The examples below are the ones already in `task-2-51-logql.md`.

## 1. Write the question before the query

One sentence, with a noun that can be checked.

- "Show lines from the monitoring namespace."
- "Keep only lines that contain the word error, and drop lines that also contain 404."
- "How many log lines per second is each namespace writing?"

If the sentence says "CPU" but the query counts log lines, the design is wrong. `rate` and `sum by` are shared words. The thing inside the parentheses decides what is being counted.

## 2. Split "already known" from "must look up"

Make two short lists before you open a doc.

Known from the cluster, not from memory:

- Namespace name, pod name, which app is in it.
- The shape of one real line: JSON `{"level":"error"}` or logfmt `level=ERROR msg="..."`.
- Whether the goal is lines on screen, or a number on a graph.

Must look up, because memory gets the syntax wrong:

- Does `=~` mean "exact"? No. Exact is `=`. `=~` is a pattern.
- Does `| json` work on `key=value` lines? No.
- Is a trailing comma inside `{}` legal? No. Loki returns 400.

Do not design the filter until the second list is answered from a source, not from a guess.

## 3. Where to gather the information

Use sources in this order. Stop when the fact is confirmed. Do not collect everything.

| Order | Source | What you take from it | What you do not take |
|---|---|---|---|
| 1 | The running system | Pod names, one real log line, labels Grafana already shows | A theory about why it failed |
| 2 | The error Loki or Grafana returned | Status code, parser error, the query that was actually sent | Your typed query, if the log shows a different one |
| 3 | Official docs | The meaning of one operator you are about to use | A full tutorial you will not run |
| 4 | Your last successful query | The selector that already returned 200 | Copying it into a new question without reading it |

### The running system

```bash
kubectl get pods -n monitoring
kubectl logs -n monitoring <pod> --tail=20
```

`kubectl get pods` gives the real pod name. Copy it. A hand-typed name with a wrong hash matches nothing.

`kubectl logs` shows the shape of the line. That shape chooses the parser.

- Line starts with `{` and is one object: `| json`
- Line is `key=value`: `| logfmt`
- You only need the word `error` somewhere in the text: `|= "error"` and no parser

In Grafana Explore, open the label browser for the Loki data source. It lists labels Loki has indexed (`namespace`, `pod`, `stream`, `container`). Those names are the only ones allowed inside `{}`. A field you hope exists, such as `level`, is not a label until a parser creates it.

### The error, not the query you meant

When Explore fails, read Grafana's own log line. The useful fields are:

- `status` — `400` means the query text is invalid. `200` means Loki accepted it.
- `status_source=downstream` — Loki rejected it. Grafana only passed the error on.
- `query` or the `referer` URL — the text Loki received. It can differ from what you think you typed (a trailing comma, extra blank lines, a second matcher).

Decode the `referer` before you edit the query. The 400 in this task was `{namespace=~".+",}` — the comma before `}` is illegal. The fix is to delete the comma, not to change the filter.

### Official docs

Open one page for the operator you are using. Do not read the whole manual.

- Log queries (selectors and filters): https://grafana.com/docs/loki/latest/query/log_queries/
- Metric queries (`rate`, `sum by`): https://grafana.com/docs/loki/latest/query/metric_queries/
- Why labels exist: https://grafana.com/docs/loki/latest/get-started/labels/

Read only the section that matches the question. If the question is "what does `|=` do", stay on the log-query page. If the question is "what does `rate(...[5m])` count", open the metric-query page and check that the input is a log selector, not a Prometheus CPU metric.

### A sample you already trust

Keep one query that returned `status=ok`. New queries should change one piece of it: add a filter, or narrow the pod, or switch to `rate`. If you change the selector and the parser and the time range together, a failure has three possible causes.

## 4. Design the query in four slots

Write it on paper in this order. Leave a slot empty if you do not need it.

1. **Selector.** Labels inside `{}`. One matcher per label. Use `=` when you know the exact value. Use `=~".+"` only when you truly mean "any non-empty value". Loki will not run `{}` with no label.
2. **Line filter.** `|=`, `!=`, `|~`, `!~`. These scan text. They are not indexed. Put the cheap selector first so Loki opens fewer streams.
3. **Parser.** `| json` or `| logfmt`, and only if you need a field from inside the line. Then filter that field: `level=~"ERROR|WARN"`. Match the case you saw in the sample. `error` does not match `ERROR`.
4. **Metric.** Only if the question asks for a number. `sum(rate({...}[5m])) by (namespace)` is lines per second, grouped by namespace. It does not read CPU or memory.

A selector chooses streams from the index. A filter reads the lines inside those streams. That is why a wide selector plus a text search is slow: Loki indexes the labels, not the words in the line.

## 5. Run it, then write

Run the draft in Explore over a short range first (`now-15m`). Then check three things:

- Did Loki return lines, or a number, or an error?
- Does one returned line actually answer the sentence from step 1?
- If you added `| json` or `| logfmt`, did the field you filter on show up? If the line carries `__error__=JSONParserErr`, the parser does not match the line. Change the parser, not the pattern.

Write the doc from that result. Include the query, what it is for, and one real line or the error. If the result is empty, say so and say why. An empty `| json` result is a finding, not a failed write-up.

## Worked pass: the JSON query

Question: "If pods in `monitoring` emit JSON, keep severity error or warn."

Facts gathered before choosing a parser:

- `kubectl logs` on Prometheus and Grafana showed `level=ERROR` and `logger=... level=info`, which is logfmt.
- One sidecar line was real JSON: `{"level":"INFO","msg":"..."}`.
- The Loki query `{namespace="monitoring"} | json | level=~"error|warn"` returned no lines.
- `| logfmt | level=~"ERROR|WARN|error|warn"` returned tens of thousands of lines.

Design decision: `| json` is the right tool only when the line is one JSON object. For this namespace the parser that answers the question is `| logfmt`, and the pattern must include the uppercase values the apps actually print.

## Checklist for the next query

- [ ] One sentence: what question does this answer?
- [ ] One real line copied from the pod or from Explore.
- [ ] Label names taken from the label browser, not invented.
- [ ] Parser chosen from the line shape, not from the task title.
- [ ] Case of `level` copied from the line.
- [ ] Query run. Status is `200`, or the `400` is explained from the query Loki received.
- [ ] The doc states what the number means if the query uses `rate` or `sum`.
