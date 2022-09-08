data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  #iam_instance_profile        = aws_iam_instance_profile.profile.name

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
