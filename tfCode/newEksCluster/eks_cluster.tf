

##
## create EKS cluster
## attaching required EKS policies
##

resource "aws_eks_cluster" "eks-cluster" {

  name     = var.cluster-name
  role_arn = aws_iam_role.eks-cluster.arn
  version  = var.eks_version
  # enabled_cluster_log_types = ["api", "audit", "scheduler", "controllerManager"]

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = concat(aws_subnet.eks-public.*.id, aws_subnet.eks-private.*.id)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}
