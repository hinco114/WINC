resource "aws_security_group" "bastion_sg" {
  name   = "${var.tag_prefix}-bastion-sg"
  vpc_id = var.vpc_id

  # lifecycle을 사용하여 외부에서 관리되는 규칙을 무시
  lifecycle {
    ignore_changes = [ingress, egress]
  }

  tags = {
    Name = "${var.tag_prefix}-bastion-sg"
  }
}

# VPC 내부 트래픽 허용 규칙
resource "aws_security_group_rule" "bastion_vpc_ingress" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr_block]
  description       = "Allow all traffic from VPC"
}

# EICE에서의 트래픽 허용 규칙
resource "aws_security_group_rule" "bastion_eice_ingress" {
  count = var.eice_sg_id != "" ? 1 : 0

  security_group_id        = aws_security_group.bastion_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.eice_sg_id
  description              = "Allow all traffic from EC2 Instance Connect Endpoint"
}

# 모든 아웃바운드 트래픽 허용
resource "aws_security_group_rule" "bastion_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_pair_name
  tags = {
    Name = "${var.tag_prefix}-bastion"
  }
}
