variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/20"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat" {
  description = "If set to true, enable auto nat gateway on private subnets"
  type        = bool
  default     = true
}

variable "s3_endpoint" {
  type    = string
  default = "com.amazonaws.us-east-1.s3"
}

variable "flow_log_iam_role" {
  type    = string
  default = "flow_log"
}

variable "flow_log_iam_role_policy" {
  type    = string
  default = "allow_logs"
}

variable "cloudwatch_vpc_flow_log_group_name" {
  type    = string
  default = "test"
}
