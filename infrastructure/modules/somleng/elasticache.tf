resource "aws_security_group" "redis" {
  name   = "${var.app_identifier}-redis"
  vpc_id = var.region.vpc.vpc_id
  ingress {
    from_port = "6379"
    to_port   = "6379"
    protocol  = "TCP"
    self      = true
  }

  tags = {
    Name = "somleng-redis"
  }
}

resource "aws_elasticache_serverless_cache" "redis" {
  engine                   = "valkey"
  name                     = var.app_identifier
  security_group_ids       = [aws_security_group.redis.id]
  subnet_ids               = var.region.vpc.database_subnets
  snapshot_retention_limit = 30
}
