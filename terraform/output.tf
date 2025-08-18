output "vpc" {
  value = module.vpc
}

output "bastion" {
  value = module.bastion
}

output "my_ip_cidr" {
  value = local.my_ip_cidr
}
