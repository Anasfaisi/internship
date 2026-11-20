terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "task-3-41-test-bucket-ac" {
  bucket = var.bucket_name

  tags = {
    Name        = "task-3-41-test-bucket-ac"
    Environment = "development"
    Task        = "3.41"
  }
}

terraform {
  backend "s3" {
    bucket       = "task-3-41-tf-state-ac"
    key          = "task-3-41/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
