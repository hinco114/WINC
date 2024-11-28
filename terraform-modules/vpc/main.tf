resource "aws_vpc" "main_vpc" {
  cidr_block           = var.ipv4_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
    Name = "${var.tag_prefix}-vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.ipv4_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = {
    Name = "${var.tag_prefix}-private-subnet-az${(count.index + 1)}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.ipv4_cidr_block, 8, length(data.aws_availability_zones.available.names) + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = {
    Name = "${var.tag_prefix}-public-subnet-az${(count.index + 1)}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

// Todo: NAT Gateway
