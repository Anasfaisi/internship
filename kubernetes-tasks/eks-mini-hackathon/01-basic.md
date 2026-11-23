# Lab 1 — Basic EKS

Time: 3 hours.

Build a cluster with Terraform, then run a small static site that keeps its files on a volume. Ingress must reach it from outside the cluster.

## 1. Cluster

New folder: `terraform/hack-eks/`. Your own files. Do not copy `task-3-48` and change the name.

The stack must have:

- A VPC `10.80.0.0/16`
- Two public subnets, two AZs in `us-east-1` (`10.80.1.0/24`, `10.80.2.0/24`)
- Subnet tags so the AWS load balancer controller, or the in-tree cloud provider, can place a public load balancer: `kubernetes.io/role/elb = 1` and `kubernetes.io/cluster/hack-eks = shared`
- EKS cluster `hack-eks`, Kubernetes `1.33` (or any `1.29+` the module accepts)
- Public and private API endpoint
- Your IAM user can run `kubectl` (`enable_cluster_creator_admin_permissions`)
- Addons: `vpc-cni` before compute, `kube-proxy`, `coredns`
- One managed node group, `t3.medium`, min `1`, desired `2`, max `3`
- Nodes in the public subnets, and each node gets a public IP (this VPC has no NAT)
- No KMS key, no control-plane log group

Apply it. Then:

```bash
aws eks update-kubeconfig --region us-east-1 --name hack-eks
kubectl get nodes
```

Both nodes must be `Ready`.

## 2. App

Namespace `hackathon`.

One Deployment, name `notes`:

- Image `nginx:1.27`
- 2 replicas
- Label `app=notes`
- A `PersistentVolumeClaim` named `notes-html`, `1Gi`, `ReadWriteOnce`
- Mount that claim on `/usr/share/nginx/html` in both replicas
- Container resources: request `50m` CPU and `64Mi` memory, limit `200m` CPU and `128Mi` memory
- `startupProbe`, `readinessProbe`, and `livenessProbe`, all HTTP `GET /` on port `80`
- `startupProbe` must allow a slow start: `failureThreshold` at least `10`, `periodSeconds` `5`
- Readiness and liveness: `periodSeconds` `10`, `failureThreshold` `3`

`ReadWriteOnce` means one node can mount the volume. With 2 replicas the second pod can stay `Pending` or `ContainerCreating` if the two pods land on different nodes. That is the point.

Fix it without dropping the volume:

- Keep 2 replicas
- Force both pods onto the same node with `podAffinity` on `app=notes` and `topologyKey: kubernetes.io/hostname`

Then both pods must be `Running` and `Ready`.

Service `notes`, `ClusterIP`, port `80` to container port `80`.

## 3. Ingress

Install the ingress-nginx Helm chart into namespace `hackathon`.

- Release name `hack-ingress`
- `controller.ingressClassResource.name` = `hack-nginx`
- `controller.scope.enabled` = `true` and scope namespace `hackathon`
- Service type `LoadBalancer`

Ingress `notes` in `hackathon`:

- Class `hack-nginx`
- Path `/` prefix to Service `notes` port `80`
- No TLS in this lab

Wait until the Service has an external hostname. Open `http://<that-hostname>/` in a browser. You must see the default nginx page, or your own `index.html`.

## 4. Prove the disk

From a pod that has the volume mounted:

```bash
kubectl -n hackathon exec deploy/notes -- sh -c 'echo hackathon > /usr/share/nginx/html/index.html'
```

Reload the site. The body must be `hackathon`.

Delete one pod. Wait until a new one is `Ready`. Reload the site. The body must still be `hackathon`.

## Checklist

- [ ] `terraform apply` finished, `kubectl get nodes` shows 2 `Ready` nodes
- [ ] `notes` has 2 `Ready` pods on the same node
- [ ] `kubectl -n hackathon describe pod` shows all three probes and the resource requests
- [ ] `kubectl -n hackathon get pvc notes-html` is `Bound`
- [ ] Browser hits the load balancer and shows `hackathon`
- [ ] After a pod delete, the page still shows `hackathon`
- [ ] You can say why the second replica needed affinity

## If you finish early

Add a `ResourceQuota` on `hackathon`: max `1` CPU, `1Gi` memory, `4` pods. Show one new pod that stays pending because of the quota, then delete that pod so the quota is not blocking lab 2.
