resource "aws_eks_node_group" "eks_node_group_ec2_public" {
  cluster_name    = var.cluster_name
  node_group_name = "ec2_example"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids = [
    aws_subnet.eks_public[0].id,
  ]
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "eks_node_group_ec2_private" {
  cluster_name    = var.cluster_name
  node_group_name = "ec2_example_private"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids = [
    aws_subnet.eks_private[0].id,
  ]
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}