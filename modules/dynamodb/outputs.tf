output "items_table_arn" {
  description = "ARN of the items table"
  value       = aws_dynamodb_table.items.arn
}

output "items_table_name" {
  description = "Name of the items table"
  value       = aws_dynamodb_table.items.name
}

output "audit_table_arn" {
  description = "ARN of the audit table"
  value       = aws_dynamodb_table.audit_log.arn
}

output "audit_table_name" {
  description = "Name of the audit table"
  value       = aws_dynamodb_table.audit_log.name
}