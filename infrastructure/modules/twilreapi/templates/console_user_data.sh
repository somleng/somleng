#!/bin/bash

yum update -y
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
amazon-linux-extras install postgresql11 -y
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# ECS config
{
  echo "ECS_CLUSTER=${cluster_name}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
