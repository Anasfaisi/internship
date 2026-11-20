output "sns_topic_arn" {
  value = module.notify_slack.slack_topic_arn
}

output "lambda_function_name" {
  value = module.notify_slack.notify_slack_lambda_function_name
}

output "cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.nginx_cpu.alarm_name
}
