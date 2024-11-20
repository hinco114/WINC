module "vpc" {
  source = "./modules/vpc"

  tag_prefix = var.tag_prefix
}

# module "ec2" {
#   source = "./modules/ec2"
#
#   tag_prefix = var.tag_prefix
# }

#module "eks-cluster" {
#  source = "./modules/eks"
#}
