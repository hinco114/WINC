module "vpc" {
  source = "./modules/vpc"

  tag = var.tag
}

