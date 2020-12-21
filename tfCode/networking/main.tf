terraform {
  required_version = ">= 0.14"
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "aws_vpc" "orleans_test" {
  provider             = aws.region_master
  cidr_block           = "12.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "orleans_test"
  }
}

resource "aws_internet_gateway" "gw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.orleans_test.id

  tags = {
    Name    = "tf_test_ig"
    TF_DATA = "gw"
  }
}

resource "aws_eip" "nat" {
  provider = aws.region_master
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  provider      = aws.region_master
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.eks_private_1.id

  depends_on = [aws_internet_gateway.gw]
}
