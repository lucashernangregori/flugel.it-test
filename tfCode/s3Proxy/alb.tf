resource "aws_lb" "traefik" {
  provider           = aws.region_master
  name               = "traefic-to-s3"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id, aws_security_group.lb_internal_traffic.id]
  subnets            = aws_subnet.test_private.*.id
}

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
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_internal_traffic" {
  provider = aws.region_master
  name     = "lb_internal_traffic"

  vpc_id = aws_vpc.test.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "lb_internal_traffic" {
  provider                 = aws.region_master
  description              = "Allow machines with the same sg to comunicate to each other"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_internal_traffic.id
  source_security_group_id = aws_security_group.lb_internal_traffic.id
  type                     = "ingress"

  depends_on = [
    aws_security_group.lb_internal_traffic
  ]
}
