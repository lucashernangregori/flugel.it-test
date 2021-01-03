output "troubleshooting_sg_id" {
  description = "Security group to troubleshoot instances"
  value       = aws_security_group.remote_troubleshooting.id
}

output "public_ip" {
  value = aws_instance.bastion.public_ip
}