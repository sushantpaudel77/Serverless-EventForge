output "events_queue_arn" {
  description = "ARN of the events queue"
  value       = aws_sqs_queue.events_queue.arn
}

output "events_queue_url" {
  description = "URL of the events queue"
  value       = aws_sqs_queue.events_queue.url
}

output "events_dlq_arn" {
  description = "ARN of the events DLQ"
  value       = aws_sqs_queue.events_dlq.arn
}

output "item_processing_queue_arn" {
  description = "ARN of the item processing queue"
  value       = aws_sqs_queue.item_processing_queue.arn
}

output "item_processing_queue_url" {
  description = "URL of the item processing queue"
  value       = aws_sqs_queue.item_processing_queue.url
}