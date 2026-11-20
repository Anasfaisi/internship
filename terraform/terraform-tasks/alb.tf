module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.1"

  name               = "task-3-46-alb"
  load_balancer_type = "application"
  internal           = false
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  create_security_group = false
  security_groups       = [aws_security_group.alb.id]
  enable_deletion_protection = false

  target_groups = {
    nginx = {
      name        = "task-3-46-tg"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = module.nginx["task-3-46-nginx-1"].id
      vpc_id      = module.vpc.vpc_id

      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200"
      }
    }
  }

  additional_target_group_attachments = {
    nginx_2 = {
      target_group_key = "nginx"
      target_id        = module.nginx["task-3-46-nginx-2"].id
      port             = 80
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward  = { target_group_key = "nginx" }
    }
  }
}
