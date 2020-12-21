resource "aws_security_group" "worker_group_mgmt_one" {
  provider    = aws.region_master
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = data.aws_vpc.orleans_test.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "12.0.0.0/8",
      "186.123.161.221/32",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  provider    = aws.region_master
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = data.aws_vpc.orleans_test.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
      "186.123.161.221/32",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  provider    = aws.region_master
  name_prefix = "all_worker_management"
  vpc_id      = data.aws_vpc.orleans_test.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "12.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
      "186.123.161.221/32",
    ]
  }
}



resource "aws_security_group" "eks_prueba_cluster" {
  provider    = aws.region_master
  name        = "prueba_cluster_sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.orleans_test.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["12.0.0.0/16"]
  }
  ingress {
    from_port = 1
    to_port   = 65000
    protocol  = "tcp"

    cidr_blocks = [
      "186.123.161.221/32",
    ]
  }

  tags = {
    Name        = "eks-prueba"
    Responsable = var.responsable
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#to the Kubernetes. You will need to replace A.B.C.D below with
#your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  provider          = aws.region_master
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_prueba_cluster.id
  to_port           = 443
  type              = "ingress"
}


