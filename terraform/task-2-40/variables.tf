variable "region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Allowed public IP ranges for EKS API access"
  type        = list(string)
}
