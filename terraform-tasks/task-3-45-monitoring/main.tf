provider "aws" {
  region = var.aws_region
}

# Read EC2 instance ID from Task 3.44 state
data "terraform_remote_state" "task_3_44" {
  backend = "s3"

  config = {
    bucket = "task-3-41-tf-state-ac"
    key    = "task-3-44-ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# Read the Slack webhook from SSM
data "aws_ssm_parameter" "slack_webhook" {
  name            = "/task-3-45/slack-webhook-url"
  with_decryption = true
}

# Create SNS topic and Slack notifier Lambda
module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "7.5.2"

  sns_topic_name       = "task-3-45-slack-alerts"
  lambda_function_name = "task-3-45-notify-slack"

  slack_webhook_url = data.aws_ssm_parameter.slack_webhook.value
  slack_channel     = var.slack_channel
  slack_username    = "cloudwatch-alert"
}

# Monitor the existing Task 3.44 EC2 instance
resource "aws_cloudwatch_metric_alarm" "nginx_cpu" {
  alarm_name        = "task-3-45-cpu-alarm-nginx"
  alarm_description = "Monitors CPU utilization of Task 3.44 Nginx EC2"

  namespace          = "AWS/EC2"
  metric_name        = "CPUUtilization"
  statistic          = "Average"
  period             = 60
  evaluation_periods = 1
  threshold          = var.alarm_threshold

  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    InstanceId = data.terraform_remote_state.task_3_44.outputs.instance_id
  }

  alarm_actions = [
    module.notify_slack.slack_topic_arn
  ]
}
