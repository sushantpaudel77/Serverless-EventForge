variable "environment" {
  description = "Environment name"
  type        = string
}

variable "items_table_arn" {
  description = "ARN of the DynamoDB items table"
  type        = string
}

variable "audit_table_arn" {
  description = "ARN of the DynamoDB audit table"
  type        = string
}

variable "event_bus_arn" {
  description = "ARN of the EventBridge event bus"
  type        = string
}

variable "events_queue_arn" {
  description = "ARN of the main events SQS queue"
  type        = string
}

variable "item_processing_queue_arn" {
  description = "ARN of the item processing SQS queue"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}