resource "aws_lb_target_group" "instance" {
  name     = "instance-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "instance" {
  target_group_arn = aws_lb_target_group.instance.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}

resource "aws_lb" "network" {
  name               = "network-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private-us-east-1a.id]
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = aws_lb.network.arn
  protocol          = "TCP"
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.instance.arn
    type             = "forward"
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "api-telegram-webhook"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_vpc_link" "api_vpc_link" {
  name               = "api-telegram-webhook-vpc-link"
  security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_ids         = [aws_subnet.private-us-east-1a.id]
}

resource "aws_apigatewayv2_integration" "api" {
  api_id = aws_apigatewayv2_api.api.id

  integration_uri    = aws_lb_listener.forward.arn
  integration_type   = "HTTP_PROXY"
  integration_method = "POST"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.api_vpc_link.id
}

resource "random_id" "random_path" {
  byte_length = 16
}

resource "aws_apigatewayv2_route" "webhook" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /${random_id.random_path.hex}"

  target = "integrations/${aws_apigatewayv2_integration.api.id}"
}
