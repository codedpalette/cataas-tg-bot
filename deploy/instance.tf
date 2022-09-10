data "aws_ami" "amzn2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  owners = ["amazon"]
}

data "aws_iam_policy_document" "assume_role_ec2_policy_document" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "role" {
  name               = "application-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2_policy_document.json
}

resource "aws_iam_instance_profile" "profile" {
  name = "application-ec2-profile"
  role = aws_iam_role.role.name
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  user_data = templatefile("${path.module}/scripts/init_ec2.sh", {
    docker = {
      image_name   = aws_ecr_repository.ecr.repository_url
      cred_helpers = jsonencode({ "credHelpers" = { "${local.registry_url}" = "ecr-login" } })
    }
    logs = {
      group_name  = aws_cloudwatch_log_group.logs.name
      stream_name = local.service_name
    }
    app = {
      port          = local.application_port,
      internal_port = local.application_internal_port,
    }
    bot_token = var.telegram_bot_token
  })
  user_data_replace_on_change = true

  tags = {
    Name = local.service_name
  }
}
