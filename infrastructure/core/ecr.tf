resource "aws_ecr_repository" "app" {
  name                 = "twilreapi"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "nginx" {
  name                 = "twilreapi-nginx"

  image_scanning_configuration {
    scan_on_push = true
  }
}
