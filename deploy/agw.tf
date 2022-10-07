resource "aws_apigatewayv2_api" "api" {
  name          = "api-telegram-webhook"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "api" {
  api_id = aws_apigatewayv2_api.api.id

  integration_uri    = "http://${aws_instance.app_server.public_ip}"
  integration_type   = "HTTP_PROXY"
  integration_method = "POST"
}

resource "random_id" "random_path" {
  byte_length = 16
}

resource "aws_apigatewayv2_route" "webhook" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /${random_id.random_path.hex}"

  target = "integrations/${aws_apigatewayv2_integration.api.id}"
}
