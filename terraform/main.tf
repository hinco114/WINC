resource "aws_eip" "nat_instance_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.tag_prefix}-nat-eip"
  }
}

module "vpc" {
  source = "../terraform-modules/vpc"

  tag_prefix = var.tag_prefix
  use_nat_instance = true
  nat_instance_arch = "arm64"
  nat_instance_type = "t4g.nano"
  eip_allocation_ids = [aws_eip.nat_instance_eip.id]
}

resource "aws_key_pair" "default_key_pair" {
  key_name = "${var.tag_prefix}-default-key-pair"
  public_key = data.local_file.id_rsa_pub.content
}

module "bastion" {
  source = "../terraform-modules/bastion"

  tag_prefix = var.tag_prefix
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  public_subnet_id = module.vpc.public_subnets[0]
  bastion_ami = data.aws_ami.amazon_linux_2023.id
  bastion_instance_type = "t3.micro"
  enable_eice_ingress = true
  eice_sg_id = module.vpc.eice_sg_id
  key_pair_name = aws_key_pair.default_key_pair.key_name
}

// Bastion 에 현재 공인 IP 주소 허용 처리
resource "aws_security_group_rule" "bastion_sg_rule" {
  security_group_id = module.bastion.bastion_sg_id

  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [local.my_ip_cidr]
}

module "eks-cluster" {
  source = "../terraform-modules/eks"

  eks_config_path = "./configs/eks-values.yaml"
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
