resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/20"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/21"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1a"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "Allow API Access"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_ssh" {
  description       = "Allow ssh (only for EC2 Instance Connect)"
  type              = "ingress"
  security_group_id = aws_security_group.ec2-sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.ec2_instance_connect_cidr
}

resource "aws_security_group_rule" "allow_ingress" {
  description       = "Allow ingress traffic"
  type              = "ingress"
  security_group_id = aws_security_group.ec2-sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = local.api_gateway_cidr
}

resource "aws_security_group_rule" "allow_egress" {
  description       = "Allow egress traffic"
  type              = "egress"
  security_group_id = aws_security_group.ec2-sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}
