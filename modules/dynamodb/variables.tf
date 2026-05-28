variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "audit_table_name" {
  description = "Name of the audit DynamoDB table"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}