output "test_bucket_name" {
  description = "Name of the Task 3.41 test bucket"
  value       = aws_s3_bucket.task-3-41-test-bucket-ac.bucket
}

output "test_bucket_arn" {
  description = "ARN of the Task 3.41 test bucket"
  value       = aws_s3_bucket.task-3-41-test-bucket-ac.arn
}
