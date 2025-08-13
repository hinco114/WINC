provider "aws" {
  region = "ap-northeast-2"
  
  default_tags {
    tags = var.common_tags
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
