terraform {
  required_version = ">= 0.13.2"
  backend "local" {}
}

resource "aws_s3_bucket" "first_bucket" {
  provider = aws.region_master
  bucket   = var.bucket_name
  acl      = "private"

  tags = {
    Name = "flugel.it challenge"
  }
}

resource "aws_s3_bucket_object" "test_files" {
  provider = aws.region_master
  for_each = toset(var.s3_test_files)
  bucket   = aws_s3_bucket.first_bucket.id
  key      = each.value
  content  = local.current_time
}
