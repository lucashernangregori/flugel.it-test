data "aws_iam_policy_document" "first_bucket_restricted" {
  provider = aws.region_master
  statement {
    sid     = "DenyAllAccountAccessExceptForAdministratorsToS3Bucket"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.first_bucket.arn,
      "${aws_s3_bucket.first_bucket.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      variable = "aws:username"
      test     = "StringNotLike"
      values   = ["cloud_user"]
    }
  }
}
