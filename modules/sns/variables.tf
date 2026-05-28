variable "environment" {
  description = "Environment name"
  type        = string
}

variable "email_endpoint" {
  description = "Email address for SNS subscription"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of SQS queue for fan-out"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}