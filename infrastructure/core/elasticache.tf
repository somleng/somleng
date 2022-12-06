resource "aws_elasticache_subnet_group" "redis" {
  name       = "somleng-redis"
  subnet_ids = local.vpc.database_subnets
}

resource "aws_security_group" "redis" {
  name   = "somleng-redis"
  vpc_id = local.vpc.vpc_id

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

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "somleng-redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
}
