## Crate EKS master security group
resource "aws_security_group" "eks_cluster" {
  name        = "terraform-eks_cluster"
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

resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_node.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_ingress_workstation_https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  to_port           = 443
  type              = "ingress"
}


##########################
# NODES
#####################
resource "aws_security_group" "eks_node" {
  name        = "eks_worker_node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = map(
    "Name", "eks-worker-node-sg",
    "kubernetes.io/cluster/${var.cluster_name}", "owned"
  )
}

resource "aws_security_group_rule" "eks_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

# HPA requires 443 to be open for k8s control plane.
resource "aws_security_group_rule" "eks_node_ingress_hpa" {
  description              = "Allow HPA to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 443
  type                     = "ingress"
}