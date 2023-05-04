# vMix Deployment

- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [Deploy](#deploy)
- [References](#references)
---
## Getting started

The following steps describe how to deploy a vMix environment using terraform.  
Read more about vMix here: https://www.vmix.com/software/  
It will deploy the following resources and applications:  

- 1 vpc  
- 2 public subnets  
- 2 private subnets  
- 2 nat gateway  
- 2 elastic ip  
- 1 chave privada  
- 1 aws key pair  
- 1 security group  
- 1 iam role  
- 1 ec2 Instance g4dn.2xlarge with:  
  > Nice DCV  
  > NVIDIA GRID Driver  
  > NDI  
  > vMix
  > Sample Audio/Video files

---
### Prerequisites

The following tools need to be installed on your system prior to deploy VMix:
- AWS Access and Secret Key with permission to create IAM roles(Administrative User);  
    - Instructions to create the keys:  
    https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey  
- AWS CLI;
    - Installation instructions:  
    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  
- jq (json processor):   
    - Installer: https://stedolan.github.io/jq/download/  
- Git;  
    - Installation instructions:  
    https://git-scm.com/book/en/v2/Getting-Started-Installing-Git  
- Terraform;
    - Installation instructions: 
    https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- Nice DCV Client;
    - Installer:  
    https://download.nice-dcv.com/  

    If you don't have an Administrative user yet, besides the root user, just walkthrough this guide:  
    https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html  

---
### Setup

To start, clone this repository using git.  
Then, follow the steps always on the repository root folder.  
If you need help to clone the repository follow this guide:  
https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository  


1. Let's create the IAM role that will be used to create the resources.  
    Firstly, get the AWS account ID running the command bellow, and note it somewhere:
    ```bash
    aws sts get-caller-identity | jq -r '.Account'
    ```  

    Create a file ``trust-policy.json`` with the following content replacing ``YOUR-AWS-ACCOUNT-ID`` with the ID informed by the command executed previously:  
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Statement1",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:root"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    ```

    Now, you need to run these commands. Remember to replace ``{YOUR-AWS-ACCOUNT-ID}``:  
    ```bash
    aws iam create-role --role-name deploy-vmix-role --assume-role-policy-document file://trust-policy.json && \
        aws iam create-policy --policy-name EC2Access --policy-document file://policies.json && \
        aws iam attach-role-policy --policy-arn arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:policy/EC2Access --role-name deploy-vmix-role && \
        aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --role-name deploy-vmix-role
    ```

2. Now it's time to configure a profile for AWS CLI using the role.  
    Add to the file ``~/.aws/credentials`` the following.  
    Here the ``{YOUR-AWS-ACCOUNT-ID}`` replacement is also necessary, and replace the {AWS-REGION} to the one desired to deploy the resources:  
    ```bash
    [vmix]
    role_arn = arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:role/deploy-vmix-role
    source_profile = default
    region = {AWS-REGION}
    ```

    If your access and secret keys are on another profile than the ``default profile`` change the ``source_profile`` value above accordingly to the profile with the keys.  
    For more information about using roles with aws cli read it here:  https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html

___
### Deploy

To create the infrastructure:  
```bash
cd terraform && \
	terraform init && \
	terraform plan -out=plan.out && \
	terraform apply plan.out && \
	aws ec2 get-password-data --instance-id $(terraform output vmix_instance_id | sed 's/"//g') --priv-launch-key ./vmix.pem --profile vmix --region us-west-1 | jq -r '.PasswordData'
```

To destroy:  
```bash
terraform plan -destroy -out plan.out && \
    terraform apply plan.out
```

---
### References ###
https://www.vmix.com/software/  
https://aws.amazon.com/blogs/media/live-video-production-using-vmix-on-amazon-ec2/  
https://docs.aws.amazon.com/dcv/latest/adminguide/what-is-dcv.html  
https://www.bensound.com/  
https://www.pexels.com/videos/ 




