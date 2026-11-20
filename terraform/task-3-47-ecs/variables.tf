variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "container_image" {
  type        = string
  description = "ECR or Docker Hub URI for the Streamlit image"
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "slack_channel" {
  type    = string

}

variable "alarm_threshold" {
  type    = number
  default = 2
}
