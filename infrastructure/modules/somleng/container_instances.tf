module "container_instances" {
  source = "../container_instances"

  identifier       = var.app_identifier
  vpc              = var.region.vpc
  instance_subnets = var.region.vpc.private_subnets
  cluster_name     = aws_ecs_cluster.cluster.name
  max_capacity     = (var.appserver_max_tasks * 2) + (var.worker_max_tasks * 2) + (var.anycable_max_tasks * 2) + (var.ws_max_tasks * 2)
}
