output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.lb.dns_name
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "alb_arn" {
  value = aws_lb.lb.arn
}

output "alb_name" {
  value = aws_lb.lb.name
}
