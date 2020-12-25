resource "aws_instance" "bastion" {
  provider                    = aws.region_master
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.lucas.key_name
  subnet_id                   = aws_subnet.test_public[0].id
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.traefik.id
  
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.remote_troubleshooting.id
  ]
}

resource "aws_security_group" "bastion" {
  provider = aws.region_master
  name     = "bastion"

  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation_external_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "remote_troubleshooting" {
  provider = aws.region_master
  name     = "troubleshooting"

  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation_external_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "remote_troubleshooting" {
  provider                 = aws.region_master
  description              = "Allow machines with the same sg to comunicate to each other"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.remote_troubleshooting.id
  source_security_group_id = aws_security_group.remote_troubleshooting.id
  type                     = "ingress"
}