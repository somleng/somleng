resource "aws_route53_record" "api" {
  zone_id = var.route53_zone.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dashboard" {
  zone_id = var.route53_zone.zone_id
  name    = var.dashboard_subdomain
  type    = "A"

  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone.zone_id
  name    = "cdn"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.dashboard.domain_name
    zone_id                = aws_cloudfront_distribution.dashboard.hosted_zone_id
    evaluate_target_health = true
  }
}


