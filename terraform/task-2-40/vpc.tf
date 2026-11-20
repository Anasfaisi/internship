module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }

  tags = {
    Project     = var.project_name
    Environment = "learning"
  }
}
