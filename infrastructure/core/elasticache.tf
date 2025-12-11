resource "aws_elasticache_subnet_group" "redis" {
  name       = "somleng-redis"
  subnet_ids = local.vpc.database_subnets
}

data "aws_security_group" "redis" {
  id = "sg-01693cc70e0e6bc55"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id                 = "somleng-redis"
  engine                     = "redis"
  node_type                  = "cache.t4g.micro"
  num_cache_nodes            = 1
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [data.aws_security_group.redis.id]
  auto_minor_version_upgrade = true
}
