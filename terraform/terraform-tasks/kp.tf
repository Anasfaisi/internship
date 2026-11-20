resource "tls_private_key" "nginx" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "nginx" {
  key_name   = "task-3-46-key"
  public_key = tls_private_key.nginx.public_key_openssh
}
