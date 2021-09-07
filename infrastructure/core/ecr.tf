resource "aws_ecrpublic_repository" "app" {
  repository_name = "somleng"
  provider = aws.us-east-1

  catalog_data {
    about_text        = "Somleng"
    architectures     = ["Linux"]
    description       = "Somleng is an Open Source Cloud Communications Platform as a Service (CPaaS). It contains an open source implementation of Twilio's REST API, as well as functionality for carrier services."
  }
}

resource "aws_ecrpublic_repository" "nginx" {
  repository_name = "somleng-nginx"
  provider = aws.us-east-1

  catalog_data {
    about_text        = "Somleng Nginx"
    architectures     = ["Linux"]
  }
}
