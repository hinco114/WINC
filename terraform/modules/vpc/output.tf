output "vpc" {
  value = aws_vpc.main_vpc
}

output "private_subnet" {
  value = aws_subnet.private_subnet
}

output "public_subnet" {
  value = aws_subnet.public_subnet
}
