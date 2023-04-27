resource "tls_private_key" "vmix-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vmix-instance" {
  key_name   = "vmix-instance"
  public_key = tls_private_key.vmix-key.public_key_openssh
}