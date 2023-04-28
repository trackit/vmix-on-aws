resource "aws_iam_role" "ssm_role_for_ec2" {
  name = "ssm_role_for_ec2"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service : [
              "ec2.amazonaws.com"
            ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  inline_policy {
    name = "ec2_ssm_policy"
    policy = jsonencode({
      Statement : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:DescribeAssociation",
            "ssm:GetDeployablePatchSnapshotForInstance",
            "ssm:GetDocument",
            "ssm:DescribeDocument",
            "ssm:GetManifest",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:ListAssociations",
            "ssm:ListInstanceAssociations",
            "ssm:PutInventory",
            "ssm:PutComplianceItems",
            "ssm:PutConfigurePackageResult",
            "ssm:UpdateAssociationStatus",
            "ssm:UpdateInstanceAssociationStatus",
            "ssm:UpdateInstanceInformation"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2messages:AcknowledgeMessage",
            "ec2messages:DeleteMessage",
            "ec2messages:FailMessage",
            "ec2messages:GetEndpoint",
            "ec2messages:GetMessages",
            "ec2messages:SendReply"
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  tags = {
    Name = "ssm_role_ec2"
  }
}

resource "aws_iam_instance_profile" "ssm_role_for_ec2" {
  name = "ssm_role_for_ec2"
  role = aws_iam_role.ssm_role_for_ec2.id
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