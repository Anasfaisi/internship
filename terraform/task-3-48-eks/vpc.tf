terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "task-3-48-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs

  public_subnets = var.public_subnet_cidrs

  public_subnet_names = [
    "task-3-48-public-subnet-1",
    "task-3-48-public-subnet-2",
  ]

  enable_nat_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  igw_tags = {
    Name = "task-3-48-igw"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}
