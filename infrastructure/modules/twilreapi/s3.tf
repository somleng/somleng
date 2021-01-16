resource "aws_s3_bucket" "uploads" {
  bucket = var.uploads_bucket
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://*.somleng.org"]
    max_age_seconds = 3000
  }
}
