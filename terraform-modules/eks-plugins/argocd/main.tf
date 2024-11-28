resource "kubernetes_secret" "github-secret" {
  metadata {
    name      = "github-secret"
    namespace = "argocd"
  }

  data = {
    privateGithubClientId=var.privateGithubClientId
    privateGithubClientSecret=var.privateGithubClientSecret
    orgGithubClientId=var.orgGithubClientId
    orgGithubClientSecret=var.orgGithubClientSecret
  }

  type = "Opaque"
}

resource "helm_release" "argocd" {
  depends_on       = [kubernetes_secret.github-secret]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.6"

  values = [
    file(var.argocd-config-path)
  ]
}
