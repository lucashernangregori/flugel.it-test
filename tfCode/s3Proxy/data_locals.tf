data "aws_ami" "ubuntu" {
  provider    = aws.region_master
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "http" "workstation_external_ip" {
  provider = http
  url      = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "available" {
  provider = aws.region_master
}

# data "aws_vpc_endpoint_service" "s3" {
#   provider     = aws.region_master
#   service      = "s3"
#   service_type = "Gateway"
# }

# data "aws_vpc_endpoint" "s3" {
#   provider     = aws.region_master
#   vpc_id       = aws_vpc.test.id
#   service_name = "com.amazonaws.us-east-1.s3"
# }

data "aws_iam_role" "s3_reader" {
  provider = aws.region_master
  name     = "s3_reader"
  # tags = {
  #   "tf_import" = "s3_reader"
  # }
}

locals {
  workstation_external_cidr = "${chomp(data.http.workstation_external_ip.body)}/32"
}
