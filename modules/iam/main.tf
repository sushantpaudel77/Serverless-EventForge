# Lambda function configurations for role creation
locals {
  lambda_functions = {
    get-items = {
      dynamodb_actions = ["dynamodb:Scan"]
      events_actions   = []
      sqs_actions      = []
      sns_actions      = []
    }
    get-item = {
      dynamodb_actions = ["dynamodb:GetItem"]
      events_actions   = []
      sqs_actions      = []
      sns_actions      = []
    }
    create-item = {
      dynamodb_actions = ["dynamodb:PutItem"]
      events_actions   = ["events:PutEvents"]
      sqs_actions      = []
      sns_actions      = []
    }
    update-item = {
      dynamodb_actions = ["dynamodb:UpdateItem"]
      events_actions   = ["events:PutEvents"]
      sqs_actions      = []
      sns_actions      = []
    }
    delete-item = {
      dynamodb_actions = ["dynamodb:DeleteItem"]
      events_actions   = ["events:PutEvents"]
      sqs_actions      = []
      sns_actions      = []
    }
    notification-processor = {
      dynamodb_actions = []
      events_actions   = []
      sqs_actions      = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      sns_actions      = ["sns:Publish"]
    }
    item-processor = {
      dynamodb_actions = ["dynamodb:PutItem"]
      events_actions   = []
      sqs_actions      = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      sns_actions      = []
    }
  }
}

# IAM Role for each Lambda function
resource "aws_iam_role" "lambda_role" {
  for_each = local.lambda_functions

  name = "${var.environment}-${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.key}-role"
  })
}

# Attach basic execution role for CloudWatch logs
resource "aws_iam_role_policy_attachment" "basic_execution" {
  for_each = local.lambda_functions

  role       = aws_iam_role.lambda_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB permissions inline policy
resource "aws_iam_role_policy" "dynamodb_access" {
  for_each = {
    for k, v in local.lambda_functions : k => v
    if length(v.dynamodb_actions) > 0
  }

  name = "${var.environment}-${each.key}-dynamodb"
  role = aws_iam_role.lambda_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = each.value.dynamodb_actions
        Resource = [
          var.items_table_arn,
          var.audit_table_arn
        ]
      }
    ]
  })
}

# EventBridge permissions inline policy
resource "aws_iam_role_policy" "eventbridge_access" {
  for_each = {
    for k, v in local.lambda_functions : k => v
    if length(v.events_actions) > 0
  }

  name = "${var.environment}-${each.key}-eventbridge"
  role = aws_iam_role.lambda_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = each.value.events_actions
        Resource = var.event_bus_arn
      }
    ]
  })
}

# SQS permissions inline policy
resource "aws_iam_role_policy" "sqs_access" {
  for_each = {
    for k, v in local.lambda_functions : k => v
    if length(v.sqs_actions) > 0
  }

  name = "${var.environment}-${each.key}-sqs"
  role = aws_iam_role.lambda_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = each.value.sqs_actions
        Resource = each.key == "notification-processor" ? var.events_queue_arn : var.item_processing_queue_arn
      }
    ]
  })
}

# SNS permissions inline policy (only for notification processor)
resource "aws_iam_role_policy" "sns_access" {
  for_each = {
    for k, v in local.lambda_functions : k => v
    if length(v.sns_actions) > 0
  }

  name = "${var.environment}-${each.key}-sns"
  role = aws_iam_role.lambda_role[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = each.value.sns_actions
        Resource = var.sns_topic_arn
      }
    ]
  })
}