output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "node_group_name" {
  description = "Managed node group name"
  value       = split(":", module.eks.eks_managed_node_groups["main"].node_group_id)[1]
}

output "cluster_iam_role_name" {
  description = "IAM role used by the EKS control plane"
  value       = module.eks.cluster_iam_role_name
}

output "update_kubeconfig_command" {
  description = "Command that points local kubectl at this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
