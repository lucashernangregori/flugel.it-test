# REQUIRED PARAMETERS
variable "name" {
  type = string
}

variable "http_listener_ports" {
  description = "A list of ports to listen on for HTTP requests."
  type        = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "allow_inbound_from_cidr_blocks" {
  description = "A list of IP addresses in CIDR notation from which the load balancer will allow incoming HTTP/HTTPS requests."
  type        = list(string)
}

# OPTIONAL PARAMETERS
variable "allow_inbound_from_security_groups" {
  description = "A list of Security Group IDs from which the load balancer will allow incoming HTTP/HTTPS requests. Any time you change this value, make sure to update var.allow_inbound_from_security_groups too!"
  type        = list(string)
  default     = []
}