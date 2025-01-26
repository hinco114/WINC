variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_email" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type    = list(string)
  default = []
}