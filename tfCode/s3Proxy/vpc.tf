resource "aws_vpc" "test" {
  provider             = aws.region_master
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "test_vpc_igw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.test.id
}

resource "aws_vpc_endpoint" "s3" {
  provider     = aws.region_master
  vpc_id       = aws_vpc.test.id
  service_name = "com.amazonaws.us-east-1.s3"
}

# resource "aws_vpc_endpoint" "s3" {
#     provider = aws.region_master
#   vpc_id       = aws_vpc.test.id
#   service_name = data.aws_vpc_endpoint_service.s3.service_name
# }

resource "aws_subnet" "test_public" {
  provider = aws.region_master
  count    = length(var.public_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.test.id

  map_public_ip_on_launch = true
}

resource "aws_route_table" "test_public" {
  provider = aws.region_master
  vpc_id   = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_vpc_igw.id
  }


}

resource "aws_route_table" "test_private" {
  provider = aws.region_master
  vpc_id   = aws_vpc.test.id

  # route {
  #   cidr_block      = "0.0.0.0/0"
  #   gateway_id = aws_vpc_endpoint.s3.id
  # }
   depends_on = [
    aws_vpc_endpoint.s3
  ]

}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  provider        = aws.region_master
  vpc_endpoint_id = data.aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.test_private.id

  depends_on = [
    aws_vpc_endpoint.s3,
    aws_route_table.test_private
  ]
}

resource "aws_route_table_association" "test_private" {
  count = length(var.private_subnets)

  provider       = aws.region_master
  subnet_id      = element(aws_subnet.test_private.*.id, count.index)
  route_table_id = aws_route_table.test_private.id
}

resource "aws_route_table_association" "test_public" {
  count = length(var.public_subnets)

  provider       = aws.region_master
  subnet_id      = element(aws_subnet.test_public.*.id, count.index)
  route_table_id = aws_route_table.test_public.id
}




resource "aws_subnet" "test_private" {
  provider = aws.region_master
  count    = length(var.private_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.test.id
}

# resource "aws_eip" "nat" {
#   provider = aws.region_master
#   vpc      = true
# }

# resource "aws_nat_gateway" "nat_gw" {
#   provider = aws.region_master
#   count    = 1

#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.test_public.*.id[count.index]
#   depends_on    = [aws_internet_gateway.test_vpc_igw]

#   tags = {
#     Name = "gw NAT"
#   }
#}