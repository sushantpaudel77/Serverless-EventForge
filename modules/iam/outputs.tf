output "lambda_roles" {
  description = "Map of Lambda role ARNs"
  value = {
    for k, v in aws_iam_role.lambda_role : k => v.arn
  }
}

output "lambda_role_names" {
  description = "Map of Lambda role names"
  value = {
    for k, v in aws_iam_role.lambda_role : k => v.name
  }
}