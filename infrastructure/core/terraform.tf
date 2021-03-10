terraform {
  backend "s3" {
    bucket  = "infrastructure.somleng.org"
    key     = "twilreapi_core.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
}
