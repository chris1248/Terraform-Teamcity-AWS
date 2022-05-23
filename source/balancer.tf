# Application Load Balancer
resource aws_lb front_end {
  name            = var.name
  subnets         = [aws_subnet.private.id, aws_subnet.public.id]
  security_groups = [aws_security_group.teamcity.id]
  internal        = false
  load_balancer_type = "application"

  tags = var.tags
}

resource aws_lb_target_group targets {
  name        = var.name
  port        = var.app_port
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  tags = var.tags
}

variable "ports" {
    type = list(number)
    default = [8443, 443]
}

data aws_acm_certificate "company" {
  domain = var.cert_domain
}

resource aws_alb_listener http_front_end {
  count = length(var.ports)
  load_balancer_arn = aws_lb.front_end.id
  port              = var.ports[count.index]
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.company.arn

  depends_on = [aws_lb_target_group.targets, aws_lb.front_end]
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.targets.arn
  }
  tags = var.tags
}