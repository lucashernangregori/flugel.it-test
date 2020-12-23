resource "aws_route_table" "eks-public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

}

resource "aws_route_table" "eks-private" {
  vpc_id = aws_vpc.eks.id

  # tags {
  #   Name = "route table for private subnets"
  # }
}

## Enable internal route for NAT gw
resource "aws_route" "nat_gtw" {
  route_table_id         = aws_route_table.eks-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}


resource "aws_route_table_association" "eks-private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.eks-private.*.id[count.index]
  route_table_id = aws_route_table.eks-private.id
}

resource "aws_route_table_association" "eks" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.eks-public.*.id[count.index]
  route_table_id = aws_route_table.eks-public.id
}