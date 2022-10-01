resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/20"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/21"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "private-us-east-1a"
  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.8.0/21"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1a"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "NAT"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "NAT"
  }

  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
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

resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private.id
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

resource "aws_security_group_rule" "allow_ssh" { #TODO: Can't use EC2 Instance Connect without public IP
  description       = "Allow SSH traffic (for EC2 Instance Connect)"
  type              = "ingress"
  security_group_id = aws_security_group.ec2-sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["18.206.107.24/29"]
}

resource "aws_security_group_rule" "allow_ingress" { #TODO: allow only 149.154.160.0/20 and 91.108.4.0/22
  description       = "Allow ingress traffic"
  type              = "ingress"
  security_group_id = aws_security_group.ec2-sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
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
