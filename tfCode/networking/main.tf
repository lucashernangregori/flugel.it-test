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

resource "aws_subnet" "eks_public_1" {
  provider                = aws.region_master
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "eks_public_1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "eks_public_2" {
  provider                = aws.region_master
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "eks_public_2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "eks_public_3" {
  provider                = aws.region_master
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "eks_public_3"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "eks_private_1" {
  provider                = aws.region_master
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "eks_private_1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
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

resource "aws_route_table" "public_route" {
  provider = aws.region_master
  vpc_id   = aws_vpc.orleans_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "aws_route_table"
  }
}

resource "aws_route_table" "private_route" {
  provider = aws.region_master
  vpc_id   = aws_vpc.orleans_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "aws_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_association_1" {
  provider       = aws.region_master
  subnet_id      = aws_subnet.eks_public_1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  provider       = aws.region_master
  subnet_id      = aws_subnet.eks_public_2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_subnet_association_3" {
  provider       = aws.region_master
  subnet_id      = aws_subnet.eks_public_3.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_subnet_association_1" {
  provider       = aws.region_master
  subnet_id      = aws_subnet.eks_private_1.id
  route_table_id = aws_route_table.private_route.id
}