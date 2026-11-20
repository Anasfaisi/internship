variable "region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Use t2.micro or t3.micro."
  }
}

variable "my_ip" {
  description = "Ip address"
  type        = string
}

variable "public_key_path" {
  description = "key path"
  type        = string
}
