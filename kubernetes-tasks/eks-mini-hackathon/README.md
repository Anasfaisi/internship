# EKS mini hackathon

Two timed labs. Same skills as the internship tasks: Terraform, EKS, resources, probes, PVC, Helm, Helmfile, cert-manager, Prometheus, Grafana, CloudNativePG.

Do lab 1 first. Lab 2 can reuse that cluster.

| Lab | File | Time | What you build |
|---|---|---|---|
| 1 Basic | [01-basic.md](01-basic.md) | 3 hours | EKS from Terraform, then one app with probes, resources, a PVC, and Ingress |
| 2 Tougher | [02-advanced.md](02-advanced.md) | 5 hours | Helmfile stack, TLS, your own Helm chart, Postgres via CNPG, one Grafana check |

## Rules

- Docs and `kubectl explain` are allowed. Do not paste yesterday's YAML in and rename it.
- Work in namespace `hackathon`.
- One cluster is enough for both labs. Name it `hack-eks`.
- Region `us-east-1`. Two public subnets. No NAT. Managed node group, `t3.medium`, desired size `2`.
- When a pod stays `Pending`, read the event before you add a node. Scale the node group to `3` only if the event says the nodes are out of CPU or memory.
- Stop the cluster when you finish. EKS charges for the control plane and for each node the whole time it exists. `terraform destroy` from the lab 1 folder.

## Done

You are done with a lab when every box in that lab's checklist is true, and you can show the commands and the objects, not only a screenshot of Grafana.
