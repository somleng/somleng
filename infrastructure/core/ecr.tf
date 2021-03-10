resource "aws_ecrpublic_repository" "app" {
  repository_name = "twilreapi"
  provider = aws.us-east-1

  catalog_data {
    about_text        = "Twilreapi /twil-reap-i/ (Twilio Rest API)"
    architectures     = ["Linux"]
    description       = "Open Source Implementation of Twilio's REST API."
  }
}

resource "aws_ecrpublic_repository" "nginx" {
  repository_name = "twilreapi-nginx"
  provider = aws.us-east-1

  catalog_data {
    about_text        = "Somleng Twilreapi Nginx"
    architectures     = ["Linux"]
  }
}
