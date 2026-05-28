output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "custom_domain_name" {
  description = "Custom domain name for API"
  value       = var.domain_name != null ? aws_apigatewayv2_domain_name.custom[0].domain_name : null
}

# Output for Route53 alias - API Gateway target domain name
output "api_gateway_domain_name" {
  description = "API Gateway domain name for Route53 alias"
  value       = var.domain_name != null ? aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].target_domain_name : null
}

# Output for Route53 alias - API Gateway hosted zone ID
output "api_gateway_zone_id" {
  description = "API Gateway hosted zone ID for Route53 alias"
  value       = var.domain_name != null ? aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].hosted_zone_id : null
}