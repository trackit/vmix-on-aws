# vMix Deployment

- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
- [References](#references)
---
## Getting started

The following steps describe how to deploy a vMix environment using terraform.  
Read more about vMix here: https://www.vmix.com/software/  
It will deploy the following resources and applications:  

- VPC
- 4 subnets (2 private and 2 public)
- 1 NAT Gateway
- Security Group Rules
- IAM Roles
- EC2 Instance g4dn.2xlarge with:
    - Nice DCV
    - NVIDIA GRID Driver
    - NDI
    - vMix

---
### Prerequisites

The following tools need to be installed on your system prior to deploy VMix:
- AWS CLI;
    - Installation instructions: 
- Git;
- Terraform;
    - Installation instructions: 
- Nice DCV Client;
    - Installer: 

---
### Setup
1. First thing to do is to configure AWS Cli.  
For it a role from the aws account that will be used to deploy is needed. Also, an Access Key and Secret Key.  
To create run the following command to configure it.  
And input the Access Key and Secret Key IDs:  
    ```bash
    aws configure
    ```
    Something like this:  
    ```bash
    $ aws configure
            AWS Access Key ID [None]: accesskey
            AWS Secret Access Key [None]: secretkey
            Default region name [None]: us-west-2
            Default output format [None]:
    ```
    Now let's create a new profile named vmix to use a specific role with due permissions.  
    Add to the file ``~/.aws/config`` the text bellow replacing ``[account-id-here]`` for your account ID.  
    The account ID can be checked on aws console top-right menu.  
    ```
    [profile vmix]
    role_arn = arn:aws:iam::[account-id-here]:role/deploy_vmix_role
    source_profile = default
    ```  
2. 


---
### References ###
https://www.vmix.com/software/  
https://aws.amazon.com/blogs/media/live-video-production-using-vmix-on-amazon-ec2/  
https://docs.aws.amazon.com/dcv/latest/adminguide/what-is-dcv.html  
https://www.bensound.com/  
https://www.pexels.com/videos/ 




