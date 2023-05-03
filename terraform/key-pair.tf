resource "tls_private_key" "vmix-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vmix-instance" {
  key_name   = var.name
  public_key = tls_private_key.vmix-key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.vmix-instance.key_name}.pem"
  content  = tls_private_key.vmix-key.private_key_pem
}
