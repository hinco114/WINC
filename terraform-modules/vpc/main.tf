resource "aws_vpc" "main_vpc" {
  cidr_block           = var.ipv4_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.tag_prefix}-vpc"
  }
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.ipv4_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.tag_prefix}-private-subnet-az${(count.index + 1)}"
  }
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.ipv4_cidr_block, 8, length(data.aws_availability_zones.available.names) + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.tag_prefix}-public-subnet-az${(count.index + 1)}"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Public Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "route_table_association" {
  count          = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Security Group for NAT Instance
resource "aws_security_group" "nat_instance_sg" {
  count = var.use_nat_instance ? 1 : 0

  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ipv4_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_prefix}-nat-instance-sg"
  }
}

# Query the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = [var.nat_instance_arch]
  }
}

# NAT Instance (Conditional creation)
resource "aws_instance" "nat_instance" {
  count = var.use_nat_instance ? 1 : 0

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nat_instance_sg[0].id]

  # Enable IP forwarding and NAT
  user_data = <<-EOF
              #!/bin/bash
              sudo sysctl -w net.ipv4.ip_forward=1
              sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF

  tags = {
    Name = "${var.tag_prefix}-nat-instance"
  }
}

# Query the NAT Instance's ENI
data "aws_network_interface" "nat_instance_eni" {
  count = var.use_nat_instance ? 1 : 0

  filter {
    name   = "attachment.instance-id"
    values = [aws_instance.nat_instance[0].id]
  }
}

# Private Route Table (Conditional creation)
resource "aws_route_table" "private_route_table" {
  count = var.use_nat_instance ? length(data.aws_availability_zones.available.names) : 0

  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_network_interface.nat_instance_eni[0].id
  }

  tags = {
    Name = "${var.tag_prefix}-private-route-table-az${(count.index + 1)}"
  }
}

# Associate NAT Instance with Private Subnet Route Table (Conditional creation)
resource "aws_route_table_association" "private_route_table_association" {
  count = var.use_nat_instance ? length(data.aws_availability_zones.available.names) : 0

  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}