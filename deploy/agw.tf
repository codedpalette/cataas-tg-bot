resource "aws_apigatewayv2_api" "api" {
  name          = "api-telegram-webhook"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "api_vpc_link" {
  name               = "api-telegram-webhook-vpc-link"
  security_group_ids = [aws_security_group.public.id]
  subnet_ids         = [aws_subnet.main.id]
}

resource "random_id" "random_path" {
  byte_length = 16
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /${random_id.random_path.hex}"

  #target = "integrations/${aws_apigatewayv2_integration.example.id}"
}
