module "eks-cluster" {
  source = "../terraform-modules/eks"
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

  secrets-store-config-path = "./configs/secretstore-values.yaml"
}
