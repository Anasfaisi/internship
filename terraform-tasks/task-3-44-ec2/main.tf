provider "aws" {
  region = var.region
}

# Read VPC information from Task 3.43
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "task-3-41-tf-state-ac"
    key    = "task-3-43-vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Find the latest Amazon Linux 2023 x86_64 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create the EC2 key pair using your existing public key
resource "aws_key_pair" "nginx" {
  key_name   = "task-3-44-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "task-3-44-key"
  }
}

# Security group in the existing VPC
resource "aws_security_group" "nginx" {
  name        = "task-3-44-nginx-sg"
  description = "HTTP public access and SSH from my IP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task-3-44-nginx-sg"
  }
}

# Create the EC2 instance through the Terraform Registry module
module "nginx" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  name                        = "task-3-44-nginx"
  ami                         = data.aws_ami.al2023.id
  ami_ssm_parameter           = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.nginx.key_name

  create_security_group = false
  vpc_security_group_ids = [
    aws_security_group.nginx.id
  ]

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf install -y nginx
    systemctl enable --now nginx
  EOF

  tags = {
    Name = "task-3-44-nginx"
  }
}
