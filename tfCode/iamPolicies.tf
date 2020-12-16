data "aws_iam_policy_document" "first_bucket_restricted" {
  statement {
    sid       = "DenyAllAccountAccessExceptForAdministrators"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.first_bucket.arn,
      "${aws_s3_bucket.first_bucket.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      variable = "aws:PrincipalArn"
      test     = "StringNotLike"
      values   = ["arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_*"]
    }
  }
}
