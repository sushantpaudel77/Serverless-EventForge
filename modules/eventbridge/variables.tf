variable "environment" {
  description = "Environment name"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue for events"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}