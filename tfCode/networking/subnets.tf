resource "aws_subnet" "eks_public_1" {
  provider                = aws.region_master
  availability_zone       = data.aws_availability_zones.available.names[0]
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
  availability_zone       = data.aws_availability_zones.available.names[1]
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
  availability_zone       = data.aws_availability_zones.available.names[2]
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
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                      = "eks_private_1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_subnet" "eks_private_2" {
  provider                = aws.region_master
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.5.0/24"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                      = "eks_private_2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_subnet" "eks_private_3" {
  provider                = aws.region_master
  availability_zone       = data.aws_availability_zones.available.names[2]
  vpc_id                  = aws_vpc.orleans_test.id
  cidr_block              = "12.0.6.0/24"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                      = "eks_private_3"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}