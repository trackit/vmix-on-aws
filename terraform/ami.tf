resource "aws_ami_copy" "vmix" {
  name              = var.name
  description       = "AMI with vMix and dependencies installed"
  source_ami_id     = var.ami
  source_ami_region = "us-west-1"

  tags = {
    Name = "vmix"
  }
}