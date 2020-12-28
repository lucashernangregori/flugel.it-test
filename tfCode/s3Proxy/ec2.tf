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
sudo apt-get update
sudo apt-get install -y docker.io
sudo mkdir /home/ubuntu/traefik/log -p
instance_profile=`curl http://169.254.169.254/latest/meta-data/iam/security-credentials/`
aws_access_key_id=`curl http://169.254.169.254/latest/meta-data/iam/security-credentials/\$${instance_profile} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g'`
aws_secret_access_key=`curl http://169.254.169.254/latest/meta-data/iam/security-credentials/\$${instance_profile} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g'`
token=`curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/\$${instance_profile} | sed -n '/Token/{p;}' | cut -f4 -d'"'`
file="test1.txt"
bucket="1flugel.it.lucashernangregori.com"
date="`date +'%a, %d %b %Y %H:%M:%S %z'`"
resource="/\$${bucket}/\$${file}"
signature_string="GET\n\n\n\$${date}\nx-amz-security-token:\$${token}\n/\$${resource}"
signature=`/bin/echo -en "\$${signature_string}" | openssl sha1 -hmac \$${aws_secret_access_key} -binary | base64`
authorization="AWS \$${aws_access_key_id}:\$${signature}"
curl -H "Date: \$${date}" -H "X-AMZ-Security-Token: \$${token}" -H "Authorization: \$${authorization}" "https://s3.amazonaws.com/\$${resource}"
echo "
providers:
  file:
    filename: \"/etc/traefik/dynamic_conf.yml\"
    watch: true
accessLog:
  filePath: \"/var/log/traefik_access.log\"
  format: json
  fields:
   defaultMode: keep
   headers:
    defaultMode: keep
api:
  insecure: true
" > /home/ubuntu/traefik/traefik.yml
echo "
http:
    routers:
      router1:
        service: s3Service
        middlewares:
          - \"authHeader\"
        rule: \"Method(\`GET\`)\"

    middlewares:
      authHeader:
        headers:
          customRequestHeaders:
            X-AMZ-Security-Token: \"\$${token}\"
            Authorization: \"\$${authorization}\"
            Date: \"\$${date}\"
            Host: \"https://s3.amazonaws.com\"
        addS3Prefix:
          addPrefix:
            prefix: \"/1flugel.it.lucashernangregori.com\"
    services:
      s3Service:
        loadBalancer:
          servers:
            - url: \"https://s3.amazonaws.com\"
" > /home/ubuntu/traefik/dynamic_conf.yml
sudo docker run -d -p 8080:8080 -p 80:80 \
-v /home/ubuntu/traefik/traefik.yml:/etc/traefik/traefik.yml \
-v /home/ubuntu/traefik/dynamic_conf.yml:/etc/traefik/dynamic_conf.yml \
-v /home/ubuntu/traefik/log:/var/log \
-v /var/run/docker.sock:/var/run/docker.sock \
--name traefik \
traefik:v2.3.6
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
  name     = "traefik"
  role     = module.s3_bucket.iam_role_name
}

resource "aws_network_interface_sg_attachment" "traefik_troubleshooting" {
  count                = var.traefik_instances_count
  provider             = aws.region_master
  security_group_id    = module.bastion_host.troubleshooting_sg_id
  network_interface_id = aws_instance.traefik[count.index].primary_network_interface_id
  depends_on           = [module.bastion_host]
}