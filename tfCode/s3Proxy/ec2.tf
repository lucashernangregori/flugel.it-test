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
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.traefik.id

  vpc_security_group_ids = [
    aws_security_group.traefik.id,
    aws_security_group.remote_troubleshooting.id
  ]
}

resource "aws_security_group" "traefik" {
  provider = aws.region_master
  name     = "traefik"

  vpc_id = aws_vpc.test.id

  #   ingress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = [local.workstation_external_cidr]
  #   }
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

resource "aws_lb" "traefik" {
  provider           = aws.region_master
  name               = "traefic-to-s3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.test_private.*.id

  #   enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }
}

resource "aws_security_group" "lb_sg" {
  provider = aws.region_master
  name     = "lb_sg"

  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end.arn
#   }
# }

resource "aws_lb_target_group" "traefik" {
  provider = aws.region_master
  name     = "traefik"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test.id

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "traefik" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.traefik.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }

  depends_on = [
    aws_lb_target_group.traefik
  ]

}

# resource "aws_lb_listener_rule" "traefik" {
#   provider     = aws.region_master
#   listener_arn = aws_lb_listener.traefik.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.traefik.arn
#   }

#     condition {
#       source_ip {
#         values = ["0.0.0.0/0"]
#       }
#     }

#   #   condition {
#   #     host_header {
#   #       values = ["example.com"]
#   #     }
#   #   }

#   depends_on = [
#     aws_lb_target_group.traefik,
#     aws_lb_target_group.traefik
#   ]
# }


resource "aws_lb_target_group_attachment" "traefik" {
  provider = aws.region_master
  count    = 2

  target_group_arn = aws_lb_target_group.traefik.arn
  target_id        = aws_instance.traefik[count.index].id
  port             = 80

  depends_on = [
    aws_lb_target_group.traefik
  ]
}


resource "aws_iam_instance_profile" "traefik" {
  provider = aws.region_master
  name     = "traefik"
  role     = aws_iam_role.s3_reader.name
}

resource "aws_iam_role" "s3_reader" {
  provider = aws.region_master

  name = "s3_reader"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "s3_reader" {
  provider = aws.region_master
  name     = "s3_reader"
  role     = aws_iam_role.s3_reader.id

#   policy = <<-EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": [
#           "s3:GetObject"
#         ],
#         "Effect": "Allow",
#         "Resource":["arn:aws:s3:::flugel.it.lucashernangregori.com/*"]
#       }
#     ]
#   }
#   EOF
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}