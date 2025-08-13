data "aws_availability_zones" "available" {
  state = "available"
}

# 최신 Amazon Linux 2023 AMI 조회
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-*"]
  }

  filter {
    name   = "architecture"
    values = [var.nat_instance_arch]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 제공된 EIP 조회
data "aws_eip" "provided" {
  count = var.use_nat_instance && length(var.eip_allocation_ids) == var.nat_instance_count ? var.nat_instance_count : 0
  id    = var.eip_allocation_ids[count.index]
}

# NAT 인스턴스 ENI 조회
data "aws_network_interface" "nat_instance_eni" {
  count = var.use_nat_instance ? var.nat_instance_count : 0

  filter {
    name   = "attachment.instance-id"
    values = [aws_instance.nat_instance[count.index].id]
  }
}
