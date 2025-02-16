variable "tag_prefix" {
  type = string
}

variable "ipv4_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "use_nat_instance" {
  type    = bool
  default = false
}

variable "nat_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "nat_instance_arch" {
  type    = string
  default = "x86_64"
}
