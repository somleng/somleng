resource "aws_lb_target_group" "this" {
  count = 2
  name = "${var.app_identifier}-${count.index}"
  port = var.webserver_container_port
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "ip"
  deregistration_delay = 60

  health_check {
    protocol = "HTTP"
    path = "/health_checks"
    healthy_threshold = 3
    interval = 10
  }
}

resource "aws_lb_listener_rule" "allow_old_api" {
  priority = 11

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].id
  }

  condition {
    host_header {
      values = ["twilreapi.somleng.org"]
    }
  }

  condition {
    path_pattern {
      values = ["/2010-04-01/*", "/services/*"]
    }
  }
}

resource "aws_lb_listener_rule" "redirect_old_dashboard" {
  priority = 12

  listener_arn = var.listener_arn

  action {
    type = "redirect"

    redirect {
      host        = "dashboard.somleng.org"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["twilreapi.somleng.org"]
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  priority = 15

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].id
  }

  condition {
    host_header {
      values = ["api.somleng.org", "dashboard.somleng.org"]
    }
  }
}
