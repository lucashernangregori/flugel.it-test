output "lb_dns_name" {
  value = module.load_balancer.lb_dns_name
}

output "bastion_host_ip" {
  value = module.bastion_host.public_ip
}