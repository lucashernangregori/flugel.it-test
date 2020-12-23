resource "aws_instance" "bastion" {
    count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = "lucas"
  subnet_id                   = aws_subnet.test_public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.eks-node.id
  ]

}

resource "aws_security_group" "traefik" {
  name = "traefik"

  vpc_id = aws_vpc.eks.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation_external_cidr]
  }

}