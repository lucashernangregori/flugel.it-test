variable "cluster-name" {
  type        = string
  default     = "myeks"
}

variable "public_subnets" {
  type        = list(string)
  description = "you can replace these values as per your choice of subnet range"
  default     = ["10.15.0.0/22", "10.15.4.0/22", "10.15.8.0/22"]
}

variable "private_subnets" {
  type        = list(string)
  description = "you can replace these values as per your choice of subnet range"
  default     = ["10.15.12.0/22", "10.15.16.0/22", "10.15.20.0/22"]
}

variable "aws_profile" {
  default     = "default"
  description = "configure AWS CLI profile"
}

variable "eks_version" {
  description = "kubernetes cluster version provided by AWS EKS - It would be like 1.12 or 1.13"
  default     = "1.18"
}

variable "region" {
  description = "Enter region you want to create EKS cluster in"
  default     = "us-east-1"

}