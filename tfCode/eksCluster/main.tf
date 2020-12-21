terraform {
  required_version = ">= 0.14"
  backend "local" {
    path = "terraform.tfstate"
  }
}


resource "aws_eks_cluster" "prueba_eks" {
  provider = aws.region_master
  name     = var.cluster_name
  role_arn = aws_iam_role.ekspruebacluster.arn
  version  = var.eks_version

  vpc_config {
    # security_group_ids = ["${aws_security_group.eks-cluster-familia.id}"]
    # subnet_ids = "${aws_subnet.familia_eks_dev.*.id}"
    security_group_ids = [aws_security_group.eks_prueba_cluster.id]
    subnet_ids = [
      data.aws_subnet.eks_public_1.id,
      //data.aws_subnet.eks_public_2.id,
      data.aws_subnet.eks_public_3.id,
      data.aws_subnet.eks_private_1.id
    ]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }

  tags = {
    Name = var.cluster_name
    #Marca = var.marca
    #Submarca = var.submarca
    #Ambiente = var.ambiente
    Responsable = var.responsable
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "eks_node_group_ec2" {
  provider        = aws.region_master
  cluster_name    = aws_eks_cluster.prueba_eks.name
  node_group_name = "ec2_example"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  #subnet_ids      = aws_subnet.example[*].id
  subnet_ids = [
    data.aws_subnet.eks_public_1.id,
    data.aws_subnet.eks_public_2.id,
    data.aws_subnet.eks_public_3.id,
    data.aws_subnet.eks_private_1.id
  ]


  #   remote_access{
  #       source_security_group_ids = [aws_security_group.eks_prueba_cluster.id]
  #   }

  scaling_config {
    desired_size = 3
    max_size     = 6
    min_size     = 3
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}