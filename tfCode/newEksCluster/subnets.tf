resource "aws_subnet" "eks_public" {
  count = length(var.public_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.eks.id

  map_public_ip_on_launch = true

  tags = map(
    "Name", "eks-public-subnet",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
  )
}

resource "aws_subnet" "eks_private" {
  count = length(var.private_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.eks.id

  tags = map(
    "Name", "eks-private-subnet",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
    "kubernetes.io/role/internal-elb", "1",
  )
}





