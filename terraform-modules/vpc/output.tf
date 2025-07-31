output "vpc_id" {
  value = aws_vpc.main_vpc.id
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
  value = aws_instance.nat_instance.*.public_ip
}

output "nat_distribution_pattern" {
  value = local.nat_distribution
  description = "Distribution pattern for NAT instances"
}
