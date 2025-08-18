data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

data "local_file" "id_rsa_pub" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}
