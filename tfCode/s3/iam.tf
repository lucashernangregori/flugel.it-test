# data "aws_iam_policy_document" "first_bucket_restricted" {
#   provider = aws.region_master
#   statement {
#     sid     = "DenyAllAccountAccessExceptForAdministratorsToS3Bucket"
#     effect  = "Deny"
#     actions = ["s3:*"]
#     resources = [
#       aws_s3_bucket.first_bucket.arn,
#       "${aws_s3_bucket.first_bucket.arn}/*",
#     ]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       variable = "aws:username"
#       test     = "StringNotLike"
#       values   = ["cloud_user","s3_reader"]
#     }
#   }
# }

## no funca
data "aws_iam_policy_document" "first_bucket_restricted" {
  provider = aws.region_master
  statement {
    sid     = "DenyAllAccountAccessExceptForAdministratorsToS3Bucket"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.first_bucket.arn,
      "${aws_s3_bucket.first_bucket.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.arn]
    }
  }

  depends_on = [  aws_iam_role.s3_reader ]
}

resource "aws_iam_role" "s3_reader" {
  provider = aws.region_master

  name = "s3_reader"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = {
    tf_import = "s3_reader"
  }
}
