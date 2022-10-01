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

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.ecr_iam_policy.json
}

data "aws_iam_policy_document" "ecr_access_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_access_policy" {
  name   = "ecr-access-policy"
  policy = data.aws_iam_policy_document.ecr_access_policy_document.json
}

resource "aws_iam_policy_attachment" "ecr_access" {
  name       = "ecr-access"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource "aws_ecr_repository" "ecr" {
  name         = local.service_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "ecr_provisioner" {
  triggers = {
    ecr_arn  = aws_ecr_repository.ecr.arn
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "../app/**.go") : filesha1(f)]))
  }

  provisioner "local-exec" { # Too lazy to setup CI/CD
    command = templatefile("${path.module}/scripts/build_and_push_docker.sh", {
      registry_url = local.registry_url
      repo_name    = aws_ecr_repository.ecr.name
      profile      = local.aws_profile
    })
    working_dir = "${path.module}/../app"
  }
}
