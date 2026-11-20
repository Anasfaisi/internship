terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  backend "s3" {
    bucket = "task-3-41-tf-state-ac"
    key    = "task-3-45-monitoring/terraform.tfstate"
    region = "us-east-1"
  }
}
