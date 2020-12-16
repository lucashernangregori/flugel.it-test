variable "profile" {
  type    = string
  default = "default"
}

variable "region_master" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "flugel.it.lucashernangregori2.com"
}

variable "s3_test_files" {
  type    = list(string)
  default = ["test1.txt", "test2.txt"]
}

locals {
  current_time = timestamp()
}