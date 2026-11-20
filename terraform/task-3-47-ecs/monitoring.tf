resource "aws_ssm_parameter" "slack_webhook_url" {
  name        = "/task-3-47/slack-webhook-url"
  description = "Slack incoming webhook for task 3.47 alarms"
  type        = "SecureString"
  value       = var.slack_webhook_url
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "7.5.2"

  sns_topic_name       = "task-3-47-slack-alerts"
  lambda_function_name = "task-3-47-notify-slack"

  slack_webhook_url = aws_ssm_parameter.slack_webhook_url.value
  slack_channel     = var.slack_channel
  slack_username    = "task-3-47-notify-slack"
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "task-3-47-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.alarm_threshold
  treat_missing_data  = "missing"

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = "task-3-47-streamlit-service"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "task-3-47-memory-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.alarm_threshold
  treat_missing_data  = "missing"

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = "task-3-47-streamlit-service"
  }

  alarm_actions = [module.notify_slack.slack_topic_arn]
}
