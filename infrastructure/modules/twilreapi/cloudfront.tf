data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "user_agent_referer_headers" {
  name = "Managed-UserAgentRefererHeaders"
}

# This sets the Access-Control-Allow-Origin to *.somleng.org
# on the response from Cloudfront to the viewer
resource "aws_cloudfront_response_headers_policy" "cors" {
  name    = "somleng-${var.app_environment}-cors-policy"

  cors_config {
    access_control_allow_origins {
      items = ["*"]
    }

    access_control_allow_headers {
      items = ["Access-Control-Allow-Origin"]
    }

    access_control_allow_methods {
      items = ["GET", "OPTIONS"]
    }

    access_control_allow_credentials = false
    origin_override = false
  }
}

resource "aws_cloudfront_distribution" "app" {
  origin {
    domain_name = aws_route53_record.app.fqdn
    origin_id   = aws_route53_record.app.fqdn

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["cdn.somleng.org"]

  enabled         = true
  is_ipv6_enabled = false

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_route53_record.app.fqdn

    viewer_protocol_policy = "redirect-to-https"
    compress = true

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.user_agent_referer_headers.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cdn_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
