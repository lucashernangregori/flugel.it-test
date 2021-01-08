# REQUIRED PARAMETERS
variable "subnet_id" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "workstation_external_cidr" {
  type = string
}

# OPTIONAL PARAMETERS
variable "instance_role_id" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}


