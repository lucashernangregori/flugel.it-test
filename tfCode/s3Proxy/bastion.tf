resource "aws_instance" "bastion" {
  provider                    = aws.region_master
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.lucas.key_name
  subnet_id                   = aws_subnet.test_public[0].id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
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

}