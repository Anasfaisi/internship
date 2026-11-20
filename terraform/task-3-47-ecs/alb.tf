module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.1"

  name    = "task-3-47-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  internal                   = false
  enable_deletion_protection = false
  create_security_group      = false
  security_groups            = [aws_security_group.alb.id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "streamlit"
      }
    }
  }

  target_groups = {
    streamlit = {
      name        = "task-3-47-tg"
      protocol    = "HTTP"
      port        = 8501
      target_type = "ip"
      vpc_id      = module.vpc.vpc_id

      health_check = {
        enabled             = true
        path                = "/_stcore/health"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
      }

      create_attachment = false
    }
  }
}
