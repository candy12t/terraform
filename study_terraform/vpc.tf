resource "aws_vpc" "study_vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_internet_gateway" "study_igw" {
  vpc_id = aws_vpc.study_vpc.id
}

# サブネット
resource "aws_subnet" "study_public_01_subent" {
  vpc_id            = aws_vpc.study_vpc.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "study_public_02_subent" {
  vpc_id            = aws_vpc.study_vpc.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "ap-northeast-1c"
}

resource "aws_subnet" "study_private_01_subent" {
  vpc_id            = aws_vpc.study_vpc.id
  cidr_block        = "10.10.20.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "study_private_02_subent" {
  vpc_id            = aws_vpc.study_vpc.id
  cidr_block        = "10.10.21.0/24"
  availability_zone = "ap-northeast-1c"
}

resource "aws_eip" "study_nat_01_eip" {
  vpc = true
}

resource "aws_eip" "study_nat_02_eip" {
  vpc = true
}

resource "aws_nat_gateway" "study_01_nat" {
  allocation_id = aws_eip.study_nat_01_eip.id
  subnet_id     = aws_subnet.study_public_01_subent.id
}

resource "aws_nat_gateway" "study_02_nat" {
  allocation_id = aws_eip.study_nat_02_eip.id
  subnet_id     = aws_subnet.study_public_02_subent.id
}

# rotue table
resource "aws_route_table" "study_public_route_table" {
  vpc_id = aws_vpc.study_vpc.id
}

resource "aws_route" "study_public" {
  route_table_id = aws_route_table.study_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.study_igw.id
}

resource "aws_route_table" "study_private_01_route_table" {
  vpc_id = aws_vpc.study_vpc.id
}

resource "aws_route" "study_private_01" {
  route_table_id = aws_route_table.study_private_01_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.study_01_nat.id
}

resource "aws_route_table" "study_private_02_route_table" {
  vpc_id = aws_vpc.study_vpc.id
}

resource "aws_route" "study_private_02" {
  route_table_id = aws_route_table.study_private_02_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.study_02_nat.id
}

# 関連付け
resource "aws_route_table_association" "study_public_01" {
  subnet_id      = aws_subnet.study_public_01_subent.id
  route_table_id = aws_route_table.study_public_route_table.id
}

resource "aws_route_table_association" "study_public_02" {
  subnet_id      = aws_subnet.study_public_02_subent.id
  route_table_id = aws_route_table.study_public_route_table.id
}

resource "aws_route_table_association" "study_private_01" {
  subnet_id      = aws_subnet.study_private_01_subent.id
  route_table_id = aws_route_table.study_private_01_route_table.id
}

resource "aws_route_table_association" "study_private_02" {
  subnet_id      = aws_subnet.study_private_02_subent.id
  route_table_id = aws_route_table.study_private_02_route_table.id
}

# セキュリティグループ
resource "aws_security_group" "study_lb_security_group" {
  name   = "lb_security_group"
  vpc_id = aws_vpc.study_vpc.id
}

resource "aws_security_group_rule" "lb" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["106.73.5.97/32"]
  security_group_id = aws_security_group.study_lb_security_group.id
}

resource "aws_security_group_rule" "lb_egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.study_lb_security_group.id
}

resource "aws_security_group" "study_ec2_security_group" {
  name   = "ec2_security_group"
  vpc_id = aws_vpc.study_vpc.id
}

resource "aws_security_group_rule" "ec2" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["106.73.5.97/32"]
  security_group_id = aws_security_group.study_ec2_security_group.id
}

resource "aws_security_group_rule" "ec2_egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.study_ec2_security_group.id
}
