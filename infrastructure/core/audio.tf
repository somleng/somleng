# Todo: Remove this infrastructure

resource "aws_s3_bucket" "audio_public" {
  bucket = "audio.somleng.org"
}

resource "aws_s3_bucket_website_configuration" "audio_public" {
  bucket = aws_s3_bucket.audio_public.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "audio_public" {
  bucket = aws_s3_bucket.audio_public.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "audio_public" {
  bucket = aws_s3_bucket.audio_public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "audio_public" {
  depends_on = [
    aws_s3_bucket_ownership_controls.audio_public,
    aws_s3_bucket_public_access_block.audio_public,
  ]

  bucket = aws_s3_bucket.audio_public.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "audio_public" {
  bucket = aws_s3_bucket.audio_public.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "audio_public" {
  bucket = aws_s3_bucket.audio_public.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : [
            "s3:GetObject"
          ],
          "Resource" : [
            "${aws_s3_bucket.audio_public.arn}/*"
          ]
        }
      ]
    }
  )
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "user_agent_referer_headers" {
  name = "Managed-UserAgentRefererHeaders"
}

resource "aws_cloudfront_distribution" "audio" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.audio_public.website_endpoint
    origin_id   = aws_s3_bucket_website_configuration.audio_public.website_endpoint

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["audio.somleng.org"]

  enabled         = true
  is_ipv6_enabled = false

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket_website_configuration.audio_public.website_endpoint

    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.user_agent_referer_headers.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "audio_public" {
  zone_id = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org.id
  name    = "audio.somleng.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.audio.domain_name
    zone_id                = aws_cloudfront_distribution.audio.hosted_zone_id
    evaluate_target_health = true
  }
}
