# SQS trigger for notification processor Lambda
resource "aws_lambda_event_source_mapping" "notification_processor" {
  event_source_arn                   = var.events_queue_arn
  function_name                      = aws_lambda_function.functions["notification-processor"].arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 0
  enabled                            = true
}

# SQS trigger for item processor Lambda
resource "aws_lambda_event_source_mapping" "item_processor" {
  event_source_arn                   = var.item_processing_queue_arn
  function_name                      = aws_lambda_function.functions["item-processor"].arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 0
  enabled                            = true
}