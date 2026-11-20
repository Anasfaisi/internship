module "nginx" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  for_each = {
    "task-3-46-nginx-1" = 0
    "task-3-46-nginx-2" = 1
  }

  name                        = each.key
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.nginx.key_name
  subnet_id                   = module.vpc.private_subnets[each.value]
  associate_public_ip_address = false
  create_security_group       = false
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>${each.key}</h1>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF
}
