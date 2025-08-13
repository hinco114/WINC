resource "aws_vpc" "main_vpc" {
  cidr_block           = var.ipv4_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.tag_prefix}-vpc"
  }
}

# Private subnets. 각 AZ에 하나씩 생성
resource "aws_subnet" "private_subnet" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.ipv4_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.tag_prefix}-private-subnet-az${(count.index + 1)}"
  }
}

# Public subnets. 각 AZ에 하나씩 생성
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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.eice_sg.id ]
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

resource "aws_instance" "nat_instance" {
  count = var.use_nat_instance ? var.nat_instance_count : 0

  lifecycle {
    ignore_changes = [
      ami, // 최초 생성이 아닌 경우 AMI 변화로 인한 인스턴스 재생성 방지
      associate_public_ip_address, // 최초 생성이 아닌 경우 공인 IP 변화로 인한 인스턴스 재생성 방지
    ]
  }

  ami                         = length(var.nat_instance_ami) > 0 ? var.nat_instance_ami : data.aws_ami.amazon_linux_2023.id
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  associate_public_ip_address = false
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.nat_instance_sg[0].id]

  # Enable IP forwarding and NAT
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y iptables iptables-services

    # IP 포워딩 활성화
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p

    # NAT 설정을 위한 iptables 규칙
    # 기본 인터페이스 이름 확인 (보통 eth0)
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    echo "INTERFACE: $INTERFACE"

    # NAT 규칙 추가
    iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
    iptables -A FORWARD -i $INTERFACE -o $INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i $INTERFACE -o $INTERFACE -j ACCEPT

    # iptables 규칙 영구 저장
    service iptables save
    systemctl enable iptables

    # SSH 보안 강화
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  tags = {
    Name = "${var.tag_prefix}-nat-instance-${count.index + 1}"
  }
}

# EIPs for NAT Instances (eip_allocation_ids 길이가 0이면 새 EIP를 각 NAT 인스턴스 수만큼 생성)
resource "aws_eip" "nat_instance_eip" {
  count  = var.use_nat_instance && length(var.eip_allocation_ids) == 0 ? var.nat_instance_count : 0
  domain = "vpc"

  tags = {
    Name = "${var.tag_prefix}-nat-eip-${count.index + 1}"
  }
}

resource "aws_eip_association" "nat_instance_eip_association" {
  count = var.use_nat_instance ? var.nat_instance_count : 0

  instance_id = aws_instance.nat_instance[count.index].id
  allocation_id = length(var.eip_allocation_ids) == 0 ? aws_eip.nat_instance_eip[count.index].id : var.eip_allocation_ids[count.index]
}

# 프라이빗 서브넷 개수와 NAT 인스턴스 개수에 따른 배치 로직
locals {
  nat_distribution = [
    for idx in range(length(data.aws_availability_zones.available.names)) :
    (idx % var.nat_instance_count) + 1
  ]

  nat_to_subnet_map = {
    for nat_idx in range(var.nat_instance_count) :
    (nat_idx + 1) => [
      for subnet_idx in range(length(data.aws_availability_zones.available.names)) :
      subnet_idx if local.nat_distribution[subnet_idx] == nat_idx + 1
    ]
  }
}

# Private subnet Route Table (조건부 생성)
resource "aws_route_table" "private_route_table" {
  count = var.use_nat_instance ? length(data.aws_availability_zones.available.names) : 0

  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_network_interface.nat_instance_eni[local.nat_distribution[count.index] - 1].id
  }

  tags = {
    Name = "${var.tag_prefix}-private-route-table-az${(count.index + 1)}"
  }
}

# NAT 인스턴스와 Private Subnet Route Table 연결 (조건부 생성)
resource "aws_route_table_association" "private_route_table_association" {
  count = var.use_nat_instance ? length(data.aws_availability_zones.available.names) : 0

  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

# EC2 Instance Connect Endpoint Security Group
resource "aws_security_group" "eice_sg" {
  name        = "ec2-instance-connect-endpoint-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
    description = "Allow SSH access from VPC"
  }

  # Outbound rules - allow connection to EC2 instances
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
    description = "Allow SSH to EC2 instances in VPC"
  }

  tags = {
    Name = "ec2-instance-connect-endpoint-sg"
  }
}

# EC2 Instance Connect Endpoint 생성
resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = aws_subnet.private_subnet[0].id
  security_group_ids = [aws_security_group.eice_sg.id]
  
  preserve_client_ip = true
  
  tags = {
    Name = "ec2-instance-connect-endpoint"
  }
}

