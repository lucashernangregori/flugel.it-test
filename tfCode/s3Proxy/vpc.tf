resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/20"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "test_vpc_igw" {
  vpc_id = aws_vpc.test.id
}

resource "aws_subnet" "test_public" {
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.test.id

  map_public_ip_on_launch = true
}

resource "aws_route_table" "test_public" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_vpc_igw.id
  }
}

resource "aws_route_table_association" "test_public" {
  subnet_id      = aws_subnet.test_public.id
  route_table_id = aws_route_table.test_public.id
}