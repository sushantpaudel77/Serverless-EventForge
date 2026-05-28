# SNS Topic for notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.environment}-notification-topic"

  tags = merge(var.tags, {
    Name = "${var.environment}-notification-topic"
  })
}

# Email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

# SQS subscription for fan-out
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sqs"
  endpoint  = var.sqs_queue_arn
}