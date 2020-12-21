data "aws_vpc" "orleans_test" {
  provider = aws.region_master
  tags = {
    Name = "orleans_test"
  }
}

data "aws_subnet" "eks_public_1" {
  provider = aws.region_master
  tags = {
    Name = "eks_public_1"
  }
}

data "aws_subnet" "eks_public_2" {
  provider = aws.region_master
  tags = {
    Name = "eks_public_2"
  }
}

data "aws_subnet" "eks_public_3" {
  provider = aws.region_master
  tags = {
    Name = "eks_public_3"
  }
}

data "aws_subnet" "eks_private_1" {
  provider = aws.region_master
  tags = {
    Name = "eks_private_1"
  }
}

data "aws_subnet" "eks_private_2" {
  provider = aws.region_master
  tags = {
    Name = "eks_private_2"
  }
}

data "aws_subnet" "eks_private_3" {
  provider = aws.region_master
  tags = {
    Name = "eks_private_3"
  }
}