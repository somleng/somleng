variable "aws_region" {
  default = "ap-southeast-1"
}

locals {
  vpc = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region.vpc
}
