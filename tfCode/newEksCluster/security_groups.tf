## Crate EKS master security group
resource "aws_security_group" "eks-cluster" {
  name        = "terraform-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = map(
    "Name", "EKS - kubernetes master sg"
  )
}

##
## Required set of ports inbound / outbound
## More details - https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
##

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-cluster.id
  source_security_group_id = aws_security_group.eks-node.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}
