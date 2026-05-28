# Main events queue - buffers EventBridge events
resource "aws_sqs_queue" "events_queue" {
  name                      = "${var.environment}-events-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600  # 4 days
  visibility_timeout_seconds = 30

  # Dead letter queue configuration
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.events_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-events-queue"
  })
}

# Events dead letter queue
resource "aws_sqs_queue" "events_dlq" {
  name                      = "${var.environment}-events-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = merge(var.tags, {
    Name = "${var.environment}-events-dlq"
  })
}

# Item processing queue - receives from SNS fan-out
resource "aws_sqs_queue" "item_processing_queue" {
  name                      = "${var.environment}-item-processing-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  visibility_timeout_seconds = 30

  tags = merge(var.tags, {
    Name = "${var.environment}-item-processing-queue"
  })
}

# Policy to allow EventBridge to send messages to events queue
resource "aws_sqs_queue_policy" "events_queue_policy" {
  queue_url = aws_sqs_queue.events_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.events_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/${var.environment}-event-bus/${var.environment}-items-event-rule"
          }
        }
      }
    ]
  })
}

# Policy to allow SNS to send messages to item processing queue
resource "aws_sqs_queue_policy" "item_processing_queue_policy" {
  queue_url = aws_sqs_queue.item_processing_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.item_processing_queue.arn
      }
    ]
  })
}

# Data sources for account and region
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}