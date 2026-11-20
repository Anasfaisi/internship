output "alb_dns_name" {
  description = "Open http://<this> for the Streamlit app"
  value       = module.alb.dns_name
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = "task-3-47-streamlit-service"
}

output "task_execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "cloudwatch_alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.cpu.alarm_name,
    aws_cloudwatch_metric_alarm.memory.alarm_name,
  ]
}
