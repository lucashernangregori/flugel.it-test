terraform {
  required_version = ">= 0.14"
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }
  tags = {
    Name = "flugel.it challenge"
  }
}

resource "aws_s3_bucket_public_access_block" "first_bucket" {
  bucket = aws_s3_bucket.first_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# //resource created to conform super linter false positive: https://github.com/accurics/terrascan/issues/359
resource "aws_s3_bucket_policy" "first_bucket" {
  bucket     = aws_s3_bucket.first_bucket.id
  policy     = data.aws_iam_policy_document.first_bucket_restricted.json
  depends_on = [aws_s3_bucket_public_access_block.first_bucket]
}

resource "aws_s3_bucket_object" "test_files" {
  for_each = toset(var.s3_test_files)
  bucket   = aws_s3_bucket.first_bucket.id
  key      = each.value
  content  = local.current_time
}
