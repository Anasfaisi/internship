
terraform {
  backend "s3" {
    bucket  = "task-3-41-tf-state-ac"
    key     = "task-3-42-iam/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
