variable "aws_region" {
  description = "Region for this stack. The task does not name one, so this is us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC"
  type        = string
  default     = "10.48.0.0/16"
}

variable "azs" {
  description = "Two Availability Zones. EKS requires at least two."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ. Nodes and the load balancer tags use these."
  type        = list(string)
  default     = ["10.48.1.0/24", "10.48.2.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name. Subnet tags must use this same name."
  type        = string
  default     = "task-3-48-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version. The task requires 1.29 or later."
  type        = string
  default     = "1.33"
}

variable "node_instance_type" {
  description = "Instance type for the managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum nodes in the managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum nodes in the managed node group"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired nodes in the managed node group"
  type        = number
  default     = 2
}
