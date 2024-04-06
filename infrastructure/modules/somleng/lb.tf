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

  listener_arn = var.listener.arn

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
    matcher           = "0"
  }
}

resource "aws_lb_listener_rule" "anycable" {
  priority = var.app_environment == "production" ? 10 : 110

  listener_arn = var.internal_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.anycable.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.anycable.fqdn
      ]
    }
  }
}

resource "aws_lb_target_group" "ws" {
  name                 = "${var.app_identifier}-ws"
  port                 = var.ws_port
  protocol             = "HTTP"
  vpc_id               = var.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    path              = var.ws_healthcheck_path
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_listener_rule" "ws" {
  priority = var.app_environment == "production" ? 16 : 116

  listener_arn = var.listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ws.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.app.fqdn
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        var.ws_path
      ]
    }
  }
}
