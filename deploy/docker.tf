data "aws_iam_policy_document" "ecr_iam_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
  }
}

resource "aws_ecr_repository" "ecr" {
  name = local.service_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.ecr_iam_policy.json
}

data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.ecr.registry_id
}

resource "docker_registry_image" "cataas-bot-image" {
  name = "${local.ecr_url}:v1"

  build {
    context  = "${path.cwd}/../app/."
    no_cache = true
    auth_config {
      host_name = split("/", local.ecr_url)[0]
      user_name = data.aws_ecr_authorization_token.token.user_name
      password  = data.aws_ecr_authorization_token.token.password
    }
  }

  depends_on = [aws_ecr_repository.ecr]
}
