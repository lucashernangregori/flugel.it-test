variable "profile" {
  type    = string
  default = "default"
}

variable "region_master" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-prueba"
}

variable "eks_version" {
  description = "AWS eks_version"
  default     = "1.18"
}

variable "my_ip" {
  type    = string
  default = "186.123.161.221/32"
}