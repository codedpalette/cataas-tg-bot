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
  name         = local.service_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  provisioner "local-exec" { # Too lazy to setup CI/CD
    command = templatefile("${path.module}/scripts/build_and_push_docker.sh", {
      registry_url = split("/", replace(self.repository_url, "https://", ""))[0]
      repo_name    = self.name
      profile      = local.aws_profile
    })
    working_dir = "${path.module}/../app"
  }
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.ecr_iam_policy.json
}

data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.ecr.registry_id
}
