terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-rc1"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_token = var.cloudflare_api_token
}


resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

resource "cloudflare_dns_record" "dns_validation" {
  zone_id = var.cloudflare_zone_id
  # use only the first domain validation option
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  content = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  comment = "DNS validation record for ACM (Automatic)"
  ttl     = 1
}
