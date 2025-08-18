output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main_vpc.cidr_block
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "nat_instance_sg" {
  value = aws_security_group.nat_instance_sg.*.id
}

output "nat_instance_public_ip" {
  description = "NAT 인스턴스에 할당된 퍼블릭 IP 목록 (외부 제공 EIP 또는 새로 생성된 EIP)"
  value = length(var.eip_allocation_ids) == 0 ? aws_eip.nat_instance_eip[*].public_ip : data.aws_eip.provided[*].public_ip
}

output "nat_distribution_pattern" {
  value = local.nat_distribution
  description = "NAT 인스턴스 배치 패턴 (각 서브넷에 할당된 NAT 인스턴스 번호)"
}

output "eice_sg_id" {
  value = aws_security_group.eice_sg.id
}
