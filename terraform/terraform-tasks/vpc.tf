data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = "task-3-46-vpc"
  cidr = "10.46.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets      = ["10.46.1.0/24", "10.46.2.0/24"]
  public_subnet_names = ["task-3-46-public-subnet-1", "task-3-46-public-subnet-2"]

  private_subnets      = ["10.46.11.0/24", "10.46.12.0/24"]
  private_subnet_names = ["task-3-46-private-subnet-1", "task-3-46-private-subnet-2"]

  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true

  create_igw = true
  igw_tags   = { Name = "task-3-46-igw" }

  enable_nat_gateway = true
  single_nat_gateway = true
  nat_gateway_tags   = { Name = "task-3-46-nat" }
}
