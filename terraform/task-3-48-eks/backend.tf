terraform{
  backend "s3" {
    bucket       = "task-3-48-tf-state-bucket-ac"
    key          = "task-3-48-eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}


