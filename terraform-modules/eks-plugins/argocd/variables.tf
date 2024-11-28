variable "privateGithubClientId" {
  description = "Github OAuth App Client ID for private repositories"
}

variable "privateGithubClientSecret" {
  description = "Github OAuth App Client Secret for private repositories"
}

variable "orgGithubClientId" {
  description = "Github OAuth App Client ID for organization repositories"
}

variable "orgGithubClientSecret" {
  description = "Github OAuth App Client Secret for organization repositories"
}

variable "argocd-config-path" {
  description = "Path to the argocd configuration file"
  default     = "./configs/argocd-values.yaml"
}
