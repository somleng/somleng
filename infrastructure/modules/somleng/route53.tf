resource "aws_route53_record" "api" {
  zone_id = var.route53_zone.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app" {
  zone_id = var.route53_zone.zone_id
  name    = var.app_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_subdomains" {
  zone_id = var.route53_zone.zone_id
  name    = "*.${var.app_subdomain}"
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone.zone_id
  name    = var.cdn_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app.domain_name
    zone_id                = aws_cloudfront_distribution.app.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "verify" {
  zone_id = var.route53_zone.zone_id
  name    = var.verify_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}
