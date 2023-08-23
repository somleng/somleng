#!/bin/bash

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# ECS config
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=${cluster_name}
ECS_RESERVED_MEMORY=256
ECS_ENABLE_CONTAINER_METADATA=true
EOF
