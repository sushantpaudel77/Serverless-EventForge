variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Main domain name for frontend"
  type        = string
}

variable "api_domain_name" {
  description = "Domain name for API"
  type        = string
}

variable "email_endpoint" {
  description = "Email for SNS notifications"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (us-east-1)"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "waf_rate_limit" {
  description = "WAF rate limit (requests per 5 min per IP)"
  type        = number
  default     = 100
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
