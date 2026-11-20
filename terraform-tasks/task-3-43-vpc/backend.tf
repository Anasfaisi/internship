
terraform {
  backend "s3" {
    bucket       = "task-3-41-tf-state-ac"
    key          = "task-3-43-vpc/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
