locals {
  vpc = data.terraform_remote_state.core_infrastructure.outputs.vpc
}

variable "aws_region" {
  default = "ap-southeast-1"
}
