resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  iam_instance_profile = var.instance_role_id == "" ? null : var.instance_role_id

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.remote_troubleshooting.id
  ]
}

resource "aws_security_group" "bastion" {
  name = "bastion"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.workstation_external_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "remote_troubleshooting" {
  name = "troubleshooting"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.workstation_external_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "remote_troubleshooting" {
  description       = "Allow machines with the same sg to comunicate to each other"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.remote_troubleshooting.id
  self              = true
  type              = "ingress"

  depends_on = [
    aws_security_group.remote_troubleshooting
  ]
}