provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
