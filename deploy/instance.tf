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
  ami                    = data.aws_ami.amzn2.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_id              = aws_subnet.public-us-east-1a.id
  iam_instance_profile   = aws_iam_instance_profile.profile.name

  user_data = templatefile("${path.module}/scripts/init_ec2.sh", {
    docker = {
      image_name   = aws_ecr_repository.ecr.repository_url
      cred_helpers = jsonencode({ "credHelpers" = { "${local.registry_url}" = "ecr-login" } })
    }
    logs = {
      group_name  = aws_cloudwatch_log_group.logs.name
      stream_name = local.service_name
    }
    bot_token   = var.telegram_bot_token
    webhook_url = "${aws_apigatewayv2_api.api.api_endpoint}/${random_id.random_path.hex}"
  })
  user_data_replace_on_change = true

  lifecycle {
    replace_triggered_by = [null_resource.ecr_provisioner.id]
  }

  tags = {
    Name = local.service_name
  }
}
