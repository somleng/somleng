resource "aws_lb_target_group" "webserver" {
  name                 = var.app_identifier
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    protocol          = "HTTP"
    path              = "/health_checks"
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_listener_rule" "webserver" {
  priority = var.app_environment == "production" ? 15 : 115

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.api.fqdn,
        aws_route53_record.verify.fqdn,
        aws_route53_record.app.fqdn,
        "*.${aws_route53_record.app.fqdn}"
      ]
    }
  }
}

resource "aws_lb_target_group" "anycable" {
  name                 = "${var.app_identifier}-anycable"
  port                 = var.anycable_rpc_port
  protocol             = "HTTP"
  protocol_version     = "GRPC"
  vpc_id               = var.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    path              = "/grpc.health.v1.Health/Check"
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_listener" "anycable" {
  load_balancer_arn = var.internal_load_balancer.arn
  port              = var.anycable_rpc_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.internal_load_balancer_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.anycable.arn
  }
}
