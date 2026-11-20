
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "task-3-43-vpc"
  cidr = var.vpc_cidr

  azs = var.azs

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]

  public_subnet_names = [
    "task-3-43-public-subnet-1",
    "task-3-43-public-subnet-2",
    "task-3-43-public-subnet-3"
  ]

  private_subnet_names = [
    "task-3-43-private-subnet-1",
    "task-3-43-private-subnet-2",
    "task-3-43-private-subnet-3"
  ]

  enable_nat_gateway = false
  single_nat_gateway = false
  public_dedicated_network_acl = true

  public_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 110
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 120
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 110
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 120
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  tags = {
    Project     = "task-3-43"
    Environment = "learning"
  }

  igw_tags = {
    Name = "task-3-43-igw"
  }

  nat_gateway_tags = {
    Name = "task-3-43-nat"
  }

  public_acl_tags = {
    Name = "task-3-43-public-nacl"
  }

  public_route_table_tags = {
    Name = "task-3-43-public-route-table"
  }

  private_route_table_tags = {
    Name = "task-3-43-private-route-table"
  }

  nat_eip_tags = {
    Name = "task-3-43-nat-eip"
  }
}

