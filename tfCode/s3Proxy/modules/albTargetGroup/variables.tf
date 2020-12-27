# REQUIRED PARAMETERS

variable "target_group_name" {
  description = "The name to use for the Target Group"
  type        = string
}

variable "port" {
  description = "The port the servers are listening on for requests."
  type        = number
}

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the Target Group"
  type        = string
}

variable "lb_arn" {
  type        = string
}

variable "instance_ids" {
  type        = list(string)
}

# OPTIONAL PARAMETERS
variable "protocol" {
  description = "The protocol to use to talk to the servers. Must be one of: HTTP, HTTPS."
  type        = string
  default     = "HTTP"
}