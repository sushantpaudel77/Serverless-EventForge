# Local configuration for all Lambda functions
locals {
  lambda_configs = {
    get-items = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        TABLE_NAME = var.items_table_name
      }
    }
    get-item = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        TABLE_NAME = var.items_table_name
      }
    }
    create-item = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        TABLE_NAME     = var.items_table_name
        EVENT_BUS_NAME = var.event_bus_name
      }
    }
    update-item = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        TABLE_NAME     = var.items_table_name
        EVENT_BUS_NAME = var.event_bus_name
      }
    }
    delete-item = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        TABLE_NAME     = var.items_table_name
        EVENT_BUS_NAME = var.event_bus_name
      }
    }
    notification-processor = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        SNS_TOPIC_ARN = var.sns_topic_arn
      }
    }
    item-processor = {
      handler     = "index.handler"
      memory_size = 128
      timeout     = 10
      env_vars = {
        AUDIT_TABLE = var.audit_table_name
      }
    }
  }
}

# Create zip files for each Lambda function
data "archive_file" "lambda_zip" {
  for_each = local.lambda_configs

  type        = "zip"
  source_dir  = "${var.lambda_source_dir}/${each.key}"
  output_path = "${path.module}/../../tmp/${var.environment}-${each.key}.zip"
}

# Lambda functions using for_each
resource "aws_lambda_function" "functions" {
  for_each = local.lambda_configs

  filename         = data.archive_file.lambda_zip[each.key].output_path
  function_name    = "${var.environment}-${each.key}"
  role             = var.lambda_roles[each.key]
  handler          = each.value.handler
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256
  runtime          = "nodejs22.x"
  memory_size      = each.value.memory_size
  timeout          = each.value.timeout

  environment {
    variables = each.value.env_vars
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.key}"
  })
}