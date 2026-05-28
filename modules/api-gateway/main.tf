# HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.environment}-items-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"] # Update to specific domain in production
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 3600
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-items-api"
  })
}

# Lambda integrations mapping
locals {
  integrations = {
    "GET /items" = {
      lambda_key = "get-items"
    }
    "GET /items/{id}" = {
      lambda_key = "get-item"
    }
    "POST /items" = {
      lambda_key = "create-item"
    }
    "PUT /items/{id}" = {
      lambda_key = "update-item"
    }
    "DELETE /items/{id}" = {
      lambda_key = "delete-item"
    }
  }
}

# Lambda integrations
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.integrations

  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_invoke_arns[each.value.lambda_key]
  integration_method = "POST"
}

# API routes
resource "aws_apigatewayv2_route" "routes" {
  for_each = local.integrations

  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = each.key
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

# API stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  tags = merge(var.tags, {
    Name = "${var.environment}-api-stage"
  })
}

# lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each = local.integrations

  statement_id  = "Allow${var.environment}APIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names[each.value.lambda_key]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}


# Custom domain configuration (only if domain_name is provided)
resource "aws_apigatewayv2_domain_name" "custom" {
  count = var.domain_name != null ? 1 : 0

  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-api-domain"
  })
}

# API mapping for custom domain
resource "aws_apigatewayv2_api_mapping" "custom" {
  count = var.domain_name != null ? 1 : 0

  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.custom[0].domain_name
  stage       = aws_apigatewayv2_stage.default.id
}

# Route53 record for custom API domain
resource "aws_route53_record" "api" {
  count = var.domain_name != null ? 1 : 0

  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
