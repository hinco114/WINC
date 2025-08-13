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
  description = "생성할 NAT 인스턴스 수 (기본값 1)"
  type        = number
  default     = 1

  validation {
    condition     = var.nat_instance_count >= 1 && var.nat_instance_count <= 4
    error_message = "NAT 인스턴스 수는 1에서 4 사이여야 합니다."
  }
}

variable "nat_instance_ami" {
  description = "NAT 인스턴스 AMI ID"
  type        = string
  default     = ""
}

variable "eip_allocation_ids" {
  description = "EIP ID 목록"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.eip_allocation_ids) == 0 || length(var.eip_allocation_ids) == var.nat_instance_count
    error_message = "EIP ID 는 비어있거나 NAT 인스턴스 수와 같아야 합니다."
  }
}
