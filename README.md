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

- 1 vpc  
- 2 public subnets  
- 2 private subnets  
- 1 nat gateway  
- 1 elastic ip  
- 1 chave privada  
- 1 aws key pair  
- 1 security group  
- 1 iam role  
- 1 ec2 Instance g4dn.2xlarge with:  
  > Nice DCV  
  > NVIDIA GRID Driver  
  > NDI  
  > vMix

---
### Prerequisites

The following tools need to be installed on your system prior to deploy VMix:
- AWS CLI;
    - Installation instructions:  
    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  
- Git;  
    - Installation instructions:  
    https://git-scm.com/book/en/v2/Getting-Started-Installing-Git  
- Terraform;
    - Installation instructions: 
    https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- Nice DCV Client;
    - Installer:  
    https://download.nice-dcv.com/  

---
### Setup
1. Firstly, create an role named ``deploy_vmix_role`` with the following AWS managed policies:  
    AmazonVPCFullAccess  
    EC2PowerUser  
   As you are already on the web console, note the aws account ID number. It is showed at top right dropdown menu.  


2. Now it's time to configure AWS Cli.  
You will need an Access Key and Secret Key.  
Create it from the console following this guide:  
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey    
Run the following command to configure AWS CLI.  
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
    The account ID can be checked on aws console top-right dropdown menu.  
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




