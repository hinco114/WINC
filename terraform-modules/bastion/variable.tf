variable "tag_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "bastion_ami" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}

variable "eice_sg_id" {
  type = string
  default = ""
}

variable "enable_eice_ingress" {
  type        = bool
  default     = false
  description = "Enable ingress rule from EC2 Instance Connect Endpoint"
}

variable "key_pair_name" {
  type = string
}
