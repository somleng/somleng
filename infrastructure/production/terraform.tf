terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "twilreapi.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_default_region
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "twilreapi_core.tfstate"
    region = var.aws_default_region
  }
}

data "terraform_remote_state" "core_infrastructure" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "core.tfstate"
    region = var.aws_default_region
  }
}
