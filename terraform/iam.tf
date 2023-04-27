resource "aws_iam_role" "ssm_role_ec2" {
  name = "ssm_role_ec2"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" ]

  tags = {
    Name = "ssm_role_ec2"
  }
}   

# resource "aws_iam_role" "deploy_vmix_role" {
#   name = "deploy_vmix_role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = {
    
#   }


#   tags = {
#     Name = "deploy_vmix_role"
#   }
# } 