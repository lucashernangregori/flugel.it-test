resource "aws_key_pair" "lucas" {
  provider   = aws.region_master
  key_name   = "lucas"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCH7wQzOi3nwLw2AZmWkXPOUFugIccH7BgX0gQ/5cXHThj9t9pjifpgIedErqyTfysxURu8qfZ22LTY8R4aDqvLPWvQ44TDIdpIQRj+goGfTj8XQjqid8GIa2IavaqQ4ADARJCNB++hpPPEJYWmvdQ6DJDL7SQbhhxjqSxCufzXMM295phpsB13iGvJb82dO0Ldr2aL3CeXJVHA5+wfQ/W9DywVHvE6iNW1jj4UC/ZZMyH96dNoBuOLjPWXrA/l/lUcjcF85upE2wYahgGI6GjrD1l5VdRDC/rQt21R5gN4Caybosf/aQo7AORVLHS5t1kziF9JuDL2w6q3GY1ASbIx"
}

resource "aws_instance" "traefik" {
  provider = aws.region_master
  count    = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.lucas.key_name
  subnet_id                   = aws_subnet.test_private[count.index].id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.traefik.id,
    aws_security_group.remote_troubleshooting.id
  ]
}

resource "aws_security_group" "traefik" {
  provider = aws.region_master
  name     = "traefik"

  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation_external_cidr]
  }
}

resource "aws_security_group" "remote_troubleshooting" {
  provider = aws.region_master
  name     = "traefik"

  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation_external_cidr]
  }
}

# resource "aws_lb" "test" {
#   name               = "traefik test"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = aws_subnet.test_public.id

# #   enable_deletion_protection = false

# #   access_logs {
# #     bucket  = aws_s3_bucket.lb_logs.bucket
# #     prefix  = "test-lb"
# #     enabled = true
# #   }
# }