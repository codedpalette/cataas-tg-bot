resource "aws_cloudwatch_log_group" "logs" {
  name              = "${local.service_name}-logs"
  retention_in_days = 30
}

data "aws_iam_policy_document" "logs_access_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs_access_policy" {
  name   = "logs-access-policy"
  policy = data.aws_iam_policy_document.logs_access_policy_document.json
}

resource "aws_iam_policy_attachment" "logs_access" {
  name       = "logs-access"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.logs_access_policy.arn
}
