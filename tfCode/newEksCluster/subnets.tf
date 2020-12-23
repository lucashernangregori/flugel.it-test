resource "aws_subnet" "eks-public" {
  count = length(var.public_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.eks.id

  map_public_ip_on_launch = true

  tags = map(
    "Name", "eks-public-subnet",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}