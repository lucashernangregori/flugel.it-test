data "aws_availability_zones" "available" {
  provider      = aws.region_master
  state         = "available"
  exclude_names = ["us-east-1e"]
}