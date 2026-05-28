output "event_bus_arn" {
  description = "EventBridge event bus ARN"
  value       = aws_cloudwatch_event_bus.custom.arn
}

output "event_bus_name" {
  description = "EventBridge event bus name"
  value       = aws_cloudwatch_event_bus.custom.name
}

output "event_rule_name" {
  description = "EventBridge rule name"
  value       = aws_cloudwatch_event_rule.items_events.name
}