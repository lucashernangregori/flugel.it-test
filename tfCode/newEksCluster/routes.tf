resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

}

resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.eks.id

}

## Enable internal route for NAT gw
resource "aws_route" "nat_gtw" {
  route_table_id         = aws_route_table.eks_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}


resource "aws_route_table_association" "eks_private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.eks_private.*.id[count.index]
  route_table_id = aws_route_table.eks_private.id
}

resource "aws_route_table_association" "eks" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.eks_public.*.id[count.index]
  route_table_id = aws_route_table.eks_public.id
}