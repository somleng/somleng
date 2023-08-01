variable "instance_type" {
  default = "t4g.small"
}

variable "identifier" {}
variable "vpc" {}
variable "instance_subnets" {}
variable "cluster_name" {}

variable "max_capacity" {
  default = 10
}
variable "security_groups" {
  default = []
}

variable associate_public_ip_address {
  default = false
}

variable "user_data" {
  type = list(
    object(
      {
        path = string,
        content = string,
        permissions = string
      }
    )
  )
  default = []
}
