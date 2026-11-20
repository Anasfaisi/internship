terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37, < 7.0"
    }
  }

  backend "s3" {
    bucket       = "task-3-41-tf-state-ac"
    key          = "task-3-46-alb/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}
