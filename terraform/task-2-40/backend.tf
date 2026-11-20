terraform {
  backend "s3" {
    bucket       = "task-2-40-bucket-anas"
    key          = "task-2-40/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
