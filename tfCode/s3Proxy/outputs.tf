output "lb_dns_name" {
  value = module.load_balancer.lb_dns_name
}

output "bastion_host_ip" {
  value = module.bastion_host.public_ip
}

output "current_time" {
  value = module.s3_bucket.current_time
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnets" {
  value = module.networking.public_subnets
}

output "private_subnets" {
  value = module.networking.private_subnets
}