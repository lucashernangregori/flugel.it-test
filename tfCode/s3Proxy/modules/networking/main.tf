terraform {
  required_version = ">= 0.14"
}

resource "aws_vpc" "test" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    "Name" = "test"
  }
}

resource "aws_internet_gateway" "test_vpc_igw" {
  vpc_id = aws_vpc.test.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.test.id
  service_name = var.s3_endpoint
}

resource "aws_subnet" "test_public" {
  count = length(var.public_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.test.id

  map_public_ip_on_launch = true

  tags = {
    "Name"  = "test_public",
    "Count" = count.index
  }
}

resource "aws_route_table" "test_public" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_vpc_igw.id
  }
}

resource "aws_route_table" "test_private" {
  vpc_id = aws_vpc.test.id

  depends_on = [
    aws_vpc_endpoint.s3
  ]
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.test_private.id

  depends_on = [
    aws_vpc_endpoint.s3,
    aws_route_table.test_private
  ]
}

resource "aws_route_table_association" "test_private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.test_private.*.id, count.index)
  route_table_id = aws_route_table.test_private.id
}

resource "aws_route_table_association" "test_public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.test_public.*.id, count.index)
  route_table_id = aws_route_table.test_public.id
}

resource "aws_subnet" "test_private" {
  count = length(var.private_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.test.id

  tags = {
    "Name"  = "test_private",
    "Count" = count.index
  }
}

resource "aws_eip" "nat" {
  count = var.enable_nat ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "nat_gw" {
  count = var.enable_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.test_public.*.id[count.index]
  depends_on    = [aws_internet_gateway.test_vpc_igw]
}

resource "aws_route" "nat_gw" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.test_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}