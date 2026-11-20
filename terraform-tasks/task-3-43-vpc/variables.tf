
variable "region" {
  description = "AWS region for the VPC"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones for the VPC"
  type        = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]
}
