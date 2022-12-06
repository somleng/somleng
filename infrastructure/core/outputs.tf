output "app_ecr_repository" {
  value = aws_ecrpublic_repository.app.repository_uri
}

output "nginx_ecr_repository" {
  value = aws_ecrpublic_repository.nginx.repository_uri
}

output "elasticache_redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}

output "redis_security_group" {
  value = aws_security_group.redis
}
