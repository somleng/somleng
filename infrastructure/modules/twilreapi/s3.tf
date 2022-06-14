resource "aws_s3_bucket" "uploads" {
  bucket = var.uploads_bucket
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["https://*"]
    max_age_seconds = 3000
  }
}


data "aws_s3_bucket" "raw_recordings" {
  bucket = var.raw_recordings_bucket_name
}
