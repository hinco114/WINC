module "eks-cluster" {
  source = "../terraform-modules/eks"

  eks_config_path =  "./configs/eks-values.yaml"
}

module "argocd" {
  source = "../terraform-modules/eks-plugins/argocd"
  depends_on = [ module.eks-cluster ]

  argocd-config-path = "./configs/argocd-values.yaml"

  privateGithubClientId = var.privateGithubClientId
  privateGithubClientSecret = var.privateGithubClientSecret
  orgGithubClientId = var.orgGithubClientId
  orgGithubClientSecret = var.orgGithubClientSecret
}

module "secrets-store" {
  source = "../terraform-modules/eks-plugins/secretstore"
  depends_on = [ module.eks-cluster ]

  secrets_store_config_path = "./configs/secretstore-values.yaml"
}


module "acm" {
  source = "../terraform-modules/acm"

  domain_name = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  cloudflare_zone_id = var.cloudflare_zone_id
  cloudflare_email = var.cloudflare_email
  cloudflare_api_token = var.cloudflare_api_token
}
