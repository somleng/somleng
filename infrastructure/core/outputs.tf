output "app_ecr_repository" {
  value = aws_ecr_repository.app.repository_url
}

output "nginx_ecr_repository" {
  value = aws_ecr_repository.nginx.repository_url
}

output "elasticache_redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "redis_security_group" {
  value = aws_security_group.redis
}
