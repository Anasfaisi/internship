module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "7.6.1"

  cluster_name = "task-3-47-cluster"

  cluster_capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
      base   = 1
    }
  }

  create_task_exec_iam_role      = false
  create_infrastructure_iam_role = false

  services = {
    task-3-47-streamlit-service = {
      family        = "task-3-47-streamlit-task"
      cpu           = 256
      memory        = 512
      desired_count = 1
      launch_type   = "FARGATE"

      enable_autoscaling             = false
      create_security_group          = false
      create_iam_role                = false
      create_task_exec_iam_role      = false
      create_task_exec_policy        = false
      create_tasks_iam_role          = false
      create_infrastructure_iam_role = false

      task_exec_iam_role_arn = aws_iam_role.execution.arn
      tasks_iam_role_arn     = aws_iam_role.task.arn

      subnet_ids         = module.vpc.private_subnets
      security_group_ids = [aws_security_group.ecs.id]
      assign_public_ip   = false

      health_check_grace_period_seconds = 120
      wait_for_steady_state             = true

      load_balancer = {
        streamlit = {
          target_group_arn = module.alb.target_groups["streamlit"].arn
          container_name   = "streamlit-app"
          container_port   = 8501
        }
      }

      container_definitions = {
        streamlit-app = {
          essential = true
          image     = var.container_image

          portMappings = [
            {
              name          = "streamlit"
              containerPort = 8501
              hostPort      = 8501
              protocol      = "tcp"
            }
          ]

          environment = [
            { name = "STREAMLIT_SERVER_PORT", value = "8501" },
            { name = "STREAMLIT_SERVER_ADDRESS", value = "0.0.0.0" },
            { name = "STREAMLIT_SERVER_HEADLESS", value = "true" },
            { name = "STREAMLIT_SERVER_ENABLE_CORS", value = "false" },
            { name = "STREAMLIT_SERVER_ENABLE_XSRF_PROTECTION", value = "false" },
            { name = "STREAMLIT_BROWSER_GATHER_USAGE_STATS", value = "false" }
          ]

          readonlyRootFilesystem                 = false
          enable_cloudwatch_logging              = true
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_name              = "/ecs/task-3-47-streamlit"
          cloudwatch_log_group_retention_in_days = 7
        }
      }
    }
  }
}
