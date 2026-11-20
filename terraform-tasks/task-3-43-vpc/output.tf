
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the three public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the three private subnets"
  value       = module.vpc.private_subnets
}

output "nat_gateway_id" {
  description = "ID of the single NAT Gateway"
  value       = try(module.vpc.natgw_ids[0], null)
}

output "public_nacl_id" {
  description = "ID of the dedicated public NACL"
  value       = module.vpc.public_network_acl_id
}
