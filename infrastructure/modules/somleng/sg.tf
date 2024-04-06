resource "aws_security_group" "appserver" {
  name   = "${var.app_identifier}-appserver"
  vpc_id = var.vpc.vpc_id
}

resource "aws_security_group_rule" "appserver_ingress" {
  type              = "ingress"
  to_port           = 80
  protocol          = "TCP"
  from_port         = 80
  security_group_id = aws_security_group.appserver.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "appserver_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.appserver.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "worker" {
  name   = "${var.app_identifier}-worker"
  vpc_id = var.vpc.vpc_id
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.worker.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "anycable" {
  name   = "${var.app_identifier}-anycable"
  vpc_id = var.vpc.vpc_id
}

resource "aws_security_group_rule" "anycable_ingress" {
  type              = "ingress"
  to_port           = var.anycable_rpc_port
  protocol          = "TCP"
  from_port         = var.anycable_rpc_port
  security_group_id = aws_security_group.anycable.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "anycable_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.anycable.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "ws" {
  name   = "${var.app_identifier}-ws"
  vpc_id = var.vpc.vpc_id
}

resource "aws_security_group_rule" "ws_ingress" {
  type              = "ingress"
  to_port           = var.ws_port
  protocol          = "TCP"
  from_port         = var.ws_port
  security_group_id = aws_security_group.ws.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ws_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.ws.id
  cidr_blocks       = ["0.0.0.0/0"]
}
