data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "task-3-47"
  cidr = "10.47.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.47.1.0/24", "10.47.2.0/24"]
  private_subnets = ["10.47.11.0/24", "10.47.12.0/24"]

  public_subnet_suffix  = "public-subnet"
  private_subnet_suffix = "private-subnet"

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  vpc_tags         = { Name = "task-3-47-vpc" }
  igw_tags         = { Name = "task-3-47-igw" }
  nat_gateway_tags = { Name = "task-3-47-nat" }
}
