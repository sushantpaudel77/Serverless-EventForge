variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_invoke_arns" {
  description = "Map of Lambda invoke ARNs"
  type        = map(string)
}

variable "lambda_function_names" {
  description = "Map of Lambda function names"
  type        = map(string)
}

variable "domain_name" {
  description = "Custom domain name for API"
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = null
}

variable "zone_id" {
  description = "Route 53 zone ID for custom domain"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}