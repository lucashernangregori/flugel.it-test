resource "aws_key_pair" "lucas" {
  provider   = aws.region_master
  key_name   = "lucas"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCH7wQzOi3nwLw2AZmWkXPOUFugIccH7BgX0gQ/5cXHThj9t9pjifpgIedErqyTfysxURu8qfZ22LTY8R4aDqvLPWvQ44TDIdpIQRj+goGfTj8XQjqid8GIa2IavaqQ4ADARJCNB++hpPPEJYWmvdQ6DJDL7SQbhhxjqSxCufzXMM295phpsB13iGvJb82dO0Ldr2aL3CeXJVHA5+wfQ/W9DywVHvE6iNW1jj4UC/ZZMyH96dNoBuOLjPWXrA/l/lUcjcF85upE2wYahgGI6GjrD1l5VdRDC/rQt21R5gN4Caybosf/aQo7AORVLHS5t1kziF9JuDL2w6q3GY1ASbIx"
}

resource "aws_instance" "traefik" {
  provider = aws.region_master
  count    = var.traefik_instances_count

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.lucas.key_name
  subnet_id                   = module.networking.private_subnets[count.index]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.traefik.id

  vpc_security_group_ids = [
    aws_security_group.traefik.id,
  ]

  user_data = <<EOF
#!/bin/bash
cd /home/ubuntu 
git clone https://github.com/lucashernangregori/traefik-plugindemo.git
cd traefik-plugindemo/traefik
echo "
http:
  routers:
    my-router:
      rule: \"Method(\`GET\`)\"
      service: service-foo
      entryPoints:
        - web
      middlewares:
        - my-plugin

  services:
   service-foo:
      loadBalancer:
        servers:
          - url: \"https://s3.${var.region_master}.amazonaws.com\"
  
  middlewares:
    my-plugin:
      plugin:
        dev:
          bucketName: \""${var.bucket_name}"\"
" > dynamic.yml
cd ..
sh build.sh
echo end
EOF

  tags = {
    "Name" = "traefik"
  }

  depends_on = [module.networking]
}

resource "aws_security_group" "traefik" {
  provider = aws.region_master
  name     = "traefik"

  vpc_id = module.networking.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = [module.load_balancer.security_group_id]
  }
}

resource "aws_iam_instance_profile" "traefik" {
  provider = aws.region_master
  name     = var.traefik_instance_profile
  role     = module.s3_bucket.iam_role_name
}

resource "aws_network_interface_sg_attachment" "traefik_troubleshooting" {
  count                = var.traefik_instances_count
  provider             = aws.region_master
  security_group_id    = module.bastion_host.troubleshooting_sg_id
  network_interface_id = aws_instance.traefik[count.index].primary_network_interface_id
  depends_on           = [module.bastion_host]
}