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
  from_port         = element(var.http_listener_ports, count.index)
  to_port           = element(var.http_listener_ports, count.index)
  protocol          = "tcp"
  security_group_id = aws_security_group.sg.id
  cidr_blocks       = var.allow_inbound_from_cidr_blocks
}

resource "aws_security_group_rule" "allow_http_inbound_from_security_groups" {
  count                    = length(var.http_listener_ports) * length(var.allow_inbound_from_security_groups)
  type                     = "ingress"
  from_port                = element(var.http_listener_ports, count.index)
  to_port                  = element(var.http_listener_ports, count.index)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = element(var.allow_inbound_from_security_groups, count.index)
}

# resource "aws_lb_target_group" "traefik" {
#   provider = aws.region_master
#   name     = "traefik"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.test.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_lb_listener" "traefik" {
#   provider          = aws.region_master
#   load_balancer_arn = aws_lb.traefik.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.traefik.arn
#   }

#   depends_on = [
#     aws_lb_target_group.traefik
#   ]
# }

# resource "aws_lb_target_group_attachment" "traefik" {
#   provider = aws.region_master
#   #count    = var.traefik_instances_count
#   count = 1

#   target_group_arn = aws_lb_target_group.traefik.arn
#   #target_id        = data.aws_instance.traefik[count.index].id
#   target_id = data.aws_instance.traefik.id
#   port      = 80

#   depends_on = [
#     aws_lb_target_group.traefik
#   ]
# }

# resource "aws_security_group" "lb_sg" {
#   provider = aws.region_master
#   name     = "lb_sg"

#   vpc_id = data.aws_vpc.test.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "lb_internal_traffic" {
#   provider = aws.region_master
#   name     = "lb_internal_traffic"

#   vpc_id = data.aws_vpc.test.id

#   ingress {
#     description = "Allow machines with the same sg to comunicate to each other"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "TCP"
#     self        = true
#   }

#   egress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_network_interface_sg_attachment" "sg_attachment" {
#   provider             = aws.region_master
#   security_group_id    = aws_security_group.lb_internal_traffic.id
#   network_interface_id = data.aws_instance.traefik.network_interface_id
# }