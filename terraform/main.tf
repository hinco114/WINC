module "vpc" {
  source = "./modules/vpc"

  tag = var.tag
}

#module "eks-cluster" {
#  source = "./modules/eks"
#}
