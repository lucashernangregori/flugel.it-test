variable "bucket_name" {
  type    = string
  default = "1flugel.it.lucashernangregori.com"
}

variable "s3_test_files" {
  type    = list(string)
  default = ["test1.txt", "test2.txt"]
}

variable "s3_iam_role" {
  type    = string
  default = "s3_reader"
}

locals {
  current_time = timestamp()
}

data "aws_caller_identity" "current" {}