output "bucket_id" {
  value = aws_s3_bucket.first_bucket.id
}

output "s3_test_files" {
  value = [
    for file in var.s3_test_files : file
  ]
}

output "current_time" {
  value = local.current_time
}