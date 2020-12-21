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

resource "aws_route_table_association" "private_subnet_association_2" {
  provider       = aws.region_master
  subnet_id      = aws_subnet.eks_private_2.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "private_subnet_association_3" {
  provider       = aws.region_master
  subnet_id      = aws_subnet.eks_private_3.id
  route_table_id = aws_route_table.private_route.id
}