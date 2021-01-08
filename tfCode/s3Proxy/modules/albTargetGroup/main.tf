terraform {
  required_version = ">= 0.14"
}


resource "aws_lb_target_group" "tg" {
  name     = var.target_group_name
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = var.lb_arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  depends_on = [
    aws_lb_target_group.tg
  ]
}

resource "aws_lb_target_group_attachment" "attachment" {
  count = length(var.instance_ids)

  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.instance_ids[count.index]
  port             = var.port

  depends_on = [
    aws_lb_target_group.tg
  ]
}