variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_roles" {
  description = "Map of Lambda role ARNs"
  type        = map(string)
}

variable "items_table_name" {
  description = "DynamoDB items table name"
  type        = string
}

variable "audit_table_name" {
  description = "DynamoDB audit table name"
  type        = string
}

variable "event_bus_name" {
  description = "EventBridge event bus name"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN"
  type        = string
}

variable "lambda_source_dir" {
  description = "Path to Lambda source code directory"
  type        = string
}

variable "events_queue_arn" {
  description = "ARN of the events SQS queue"
  type        = string
}

variable "item_processing_queue_arn" {
  description = "ARN of the item processing SQS queue"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

