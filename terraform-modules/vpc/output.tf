output "vpc" {
  value = aws_vpc.main_vpc.id
}

output "private_subnet" {
  value = aws_subnet.private_subnet.*.id
}

output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}

output "nat_instance_sg" {
  value = aws_security_group.nat_instance_sg.*.id
}

output "nat_subnet" {
  value = aws_subnet.nat_subnet.*.id
}


