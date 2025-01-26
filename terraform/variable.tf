variable "tag_prefix" {
  type    = string
  default = "WINC"
}

variable "privateGithubClientId" {
  type = string
}

variable "privateGithubClientSecret" {
  type = string
}

variable "orgGithubClientId" {
  type = string
}

variable "orgGithubClientSecret" {
  type = string
}

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
