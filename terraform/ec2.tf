resource "aws_instance" "vmix" {
  ami                  = var.ami #Amazon Linux 2 AMI Win Server 2019 with NVIDIA GRID
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ssm_role_for_ec2.name
  # iam_instance_profile        = aws_iam_role.ssm_role_for_ec2.id #IAM Role to attach to the instance
  subnet_id                   = module.vpc.public_subnets[0] #The first public subnet created by the module
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vmix-instance.id
  vpc_security_group_ids      = [aws_security_group.vmix.id]
  get_password_data           = "true"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "50"
    volume_type = "gp3"
  }

  user_data = file("dcv.ps1")

  tags = {
    Terraform = "true"
    Name      = "vmix"
  }
}