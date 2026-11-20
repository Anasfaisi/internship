variable "aws_region" {
  description = "AWS region for monitoring resources"
  type        = string
  default     = "ap-south-1"
}

variable "slack_channel" {
  description = "Slack channel for alerts"
  type        = string
  default     = "aws-notifications"
}

variable "alarm_threshold" {
  description = "CPU utilization threshold for testing"
  type        = number
  default     = 2
}
