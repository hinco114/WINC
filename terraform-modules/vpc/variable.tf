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
  default = "t3.micro"
}

variable "nat_instance_arch" {
  type    = string
  default = "x86_64"
}

variable "nat_instance_count" {
  description = "Number of NAT instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.nat_instance_count >= 1 && var.nat_instance_count <= 4
    error_message = "NAT instance count must be between 1 and 4"
  }
}

variable "nat_instance_ami" {
  description = "AMI ID for the NAT instance"
  type        = string
  default     = ""
}
