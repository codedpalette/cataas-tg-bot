data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  owners = ["amazon"]
}

variable "telegram_bot_token" {
  description = "Telegram bot token"
  type        = string
  sensitive   = true
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  user_data = templatefile("${path.module}/scripts/init_ec2.sh", {
    docker_user               = data.aws_ecr_authorization_token.token.user_name,
    docker_password           = data.aws_ecr_authorization_token.token.password,
    docker_repository         = aws_ecr_repository.ecr.repository_url,
    docker_image_name         = replace(aws_ecr_repository.ecr.repository_url, "https://", ""),
    application_port          = local.application_port,
    application_internal_port = local.application_internal_port,
    bot_token                 = var.telegram_bot_token
  })
  user_data_replace_on_change = true

  tags = {
    Name = local.service_name
  }

  depends_on = [aws_internet_gateway.gateway, aws_ecr_repository.ecr]
}
