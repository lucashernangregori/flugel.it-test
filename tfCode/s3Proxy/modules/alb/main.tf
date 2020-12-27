terraform {
  required_version = ">= 0.14"
}

resource "aws_lb" "lb" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.subnet_ids
}

resource "aws_security_group" "sg" {
  name   = "${var.name}-lb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_inbound_from_cidr_blocks" {
  count             = length(var.http_listener_ports)
  type              = "ingress"
  from_port         = var.http_listener_ports[count.index]
  to_port           = var.http_listener_ports[count.index]
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = var.allow_inbound_from_cidr_blocks
}

resource "aws_security_group_rule" "allow_http_inbound_from_security_groups" {
  count                    = length(var.http_listener_ports) * length(var.allow_inbound_from_security_groups)
  type                     = "ingress"
  from_port                = var.http_listener_ports[count.index]
  to_port                  = var.http_listener_ports[count.index]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = var.allow_inbound_from_security_groups[count.index]
}