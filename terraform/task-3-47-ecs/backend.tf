terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.41"
    }
  }

  backend "s3" {
    bucket = "task-3-41-tf-state-ac"
    key    = "task-3-47-ecs/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}
