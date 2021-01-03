variable "profile" {
  type    = string
  default = "default"
}

variable "region_master" {
  type    = string
  default = "us-east-1"
}

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

variable "traefik_instances_count" {
  type    = number
  default = 1
}

variable "enable_nat" {
  description = "If set to true, enable auto nat gateway on private subnets"
  type        = bool
  default     = true
}

variable "s3_endpoint" {
  type = string
  default = "com.amazonaws.us-east-1.s3"
}

variable "s3_iam_role" {
  type    = string
  default = "s3_reader"
}

variable "bucket_name" {
  type    = string
  default = "1flugel.it.lucashernangregori.com"
}

variable "s3_test_files" {
  type    = list(string)
  default = ["test1.txt", "test2.txt"]
}