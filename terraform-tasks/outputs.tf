
output "iam_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.app_role.arn
}

output "custom_s3_policy_arn" {
  description = "ARN of the customer managed S3 policy"
  value       = aws_iam_policy.custom_s3.arn
}
