# Main items table
resource "aws_dynamodb_table" "items" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = merge(var.tags, {
    Name = var.table_name
  })
}

# Audit log table for item-processor Lambda
resource "aws_dynamodb_table" "audit_log" {
  name         = var.audit_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "itemId"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "itemId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = merge(var.tags, {
    Name = var.audit_table_name
  })
}