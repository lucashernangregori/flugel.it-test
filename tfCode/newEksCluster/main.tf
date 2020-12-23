resource "aws_vpc" "eks" {
  cidr_block           = "10.15.0.0/19"
  enable_dns_hostnames = true

  tags = map(
    "Name", "eks-vpc",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks.id

  # tags {
  #   Name = "eks-internet-gateway"
  # }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  count = 1

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.eks-public.*.id[count.index] #public subnet 
  depends_on    = ["aws_internet_gateway.eks-igw"]

  tags = {
    Name = "gw NAT"
  }
}