terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# DynamoDB Module
module "dynamodb" {
  source = "../../modules/dynamodb"

  environment      = var.environment
  table_name       = "${var.environment}-items-table"
  audit_table_name = "${var.environment}-audit-log"
  tags             = var.tags
}

# SQS Module
module "sqs" {
  source = "../../modules/sqs"

  environment = var.environment
  tags        = var.tags
}

# EventBridge Module
module "eventbridge" {
  source = "../../modules/eventbridge"

  environment   = var.environment
  sqs_queue_arn = module.sqs.events_queue_arn
  tags          = var.tags
}

# SNS Module
module "sns" {
  source = "../../modules/sns"

  environment    = var.environment
  email_endpoint = var.email_endpoint
  sqs_queue_arn  = module.sqs.item_processing_queue_arn
  tags           = var.tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  environment               = var.environment
  items_table_arn           = module.dynamodb.items_table_arn
  audit_table_arn           = module.dynamodb.audit_table_arn
  event_bus_arn             = module.eventbridge.event_bus_arn
  events_queue_arn          = module.sqs.events_queue_arn
  item_processing_queue_arn = module.sqs.item_processing_queue_arn
  sns_topic_arn             = module.sns.topic_arn
  tags                      = var.tags
}

module "lambda" {
  source = "../../modules/lambda"

  environment               = var.environment
  lambda_roles              = module.iam.lambda_roles
  items_table_name          = module.dynamodb.items_table_name
  audit_table_name          = module.dynamodb.audit_table_name
  event_bus_name            = module.eventbridge.event_bus_name
  sns_topic_arn             = module.sns.topic_arn
  events_queue_arn          = module.sqs.events_queue_arn
  item_processing_queue_arn = module.sqs.item_processing_queue_arn
  lambda_source_dir         = "${path.module}/../../lambda-code"
  tags                      = var.tags
}

# API Gateway Module
module "api_gateway" {
  source = "../../modules/api-gateway"

  environment           = var.environment
  lambda_invoke_arns    = module.lambda.function_invoke_arns
  lambda_function_names = module.lambda.function_names
  domain_name           = var.api_domain_name
  acm_certificate_arn   = var.acm_certificate_arn
  zone_id               = var.zone_id
  tags                  = var.tags
}

# Frontend Hosting Module
module "frontend" {
  source = "../../modules/frontend-hosting"

  environment         = var.environment
  domain_name         = var.domain_name
  acm_certificate_arn = var.acm_certificate_arn
  zone_id             = var.zone_id
  tags                = var.tags
}

# WAF Module
module "waf" {
  source = "../../modules/waf"

  environment     = var.environment
  cloudfront_arn  = module.frontend.cloudfront_arn 
  rate_limit      = var.waf_rate_limit
  tags            = var.tags
}
