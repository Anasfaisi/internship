output "alb_dns_name" {
  value = module.alb.dns_name
}

output "ec2_private_ips" {
  value = { for name, instance in module.nginx : name => instance.private_ip }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
