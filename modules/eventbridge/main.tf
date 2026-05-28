# Custom event bus
resource "aws_cloudwatch_event_bus" "custom" {
  name = "${var.environment}-event-bus"

  tags = merge(var.tags, {
    Name = "${var.environment}-event-bus"
  })
}

# Event rule to match API events
resource "aws_cloudwatch_event_rule" "items_events" {
  name           = "${var.environment}-items-event-rule"
  event_bus_name = aws_cloudwatch_event_bus.custom.name

  event_pattern = jsonencode({
    source      = ["items.api"]
    detail-type = ["ItemCreated", "ItemUpdated", "ItemDeleted"]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-items-event-rule"
  })
}

# Target: Send matched events to SQS
resource "aws_cloudwatch_event_target" "sqs" {
  rule           = aws_cloudwatch_event_rule.items_events.name
  event_bus_name = aws_cloudwatch_event_bus.custom.name
  arn            = var.sqs_queue_arn
  target_id      = "${var.environment}-events-sqs"
}