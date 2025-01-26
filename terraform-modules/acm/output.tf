output "cert" {
    value = {
        domain_validation_options = aws_acm_certificate.cert.domain_validation_options
    }
}