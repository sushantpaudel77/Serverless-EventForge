output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.api_gateway.api_endpoint
}

output "api_custom_domain" {
  description = "API custom domain"
  value       = "https://${var.api_domain_name}"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = module.frontend.frontend_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.frontend.cloudfront_id
}

output "frontend_bucket_name" {
  description = "S3 bucket for frontend"
  value       = module.frontend.bucket_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = module.sns.topic_arn
}

output "dynamodb_table" {
  description = "DynamoDB table name"
  value       = module.dynamodb.items_table_name
}