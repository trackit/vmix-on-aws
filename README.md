<div align="center">
    <img src="vmix-aws.png" width="120" height="120" alt="vmix-aws"/>
</div>

<h3 align="center">vMix on AWS</h3>

<p align="center">
Running vMix software on the cloud
</p>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#getting-started">Getting started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#setup">Setup</a></li>
        <li><a href="#deploy">Deploy</a></li>
      </ul>
    </li>
    <li>
      <a href="#references">References</a>
    </li>
  </ol>
</details>
<br/>

# Getting started

The following steps describe how to deploy a vMix environment using terraform.  
Read more about vMix here: https://www.vmix.com/software/  
It will deploy the following resources and applications (default):

### Network

> 1 VPC <br/>
> 2 Public Subnets* <br/>
> 2 Private Subnets* <br/>
> 2 NAT Gateway* <br/>
> 2 Elastic IPs* <br/>
> 1 Security Group <br/>

### IAM

> 1 Role

### EC2

> 1 Private Key <br/>
> 1 AWS Key Pair <br/>
> 1 EC2 **g4dn.2xlarge** instance with:
>> Nice DCV  
> > NVIDIA GRID Driver  
> > NDI  
> > vMix
> > Sample Audio/Video files

*Those resource will depend on how many subnets you want to your infrastructure.  
The guide assumes 2 subnets are enough. Though you can change it setting the ``private_subnets`` and ``public_subnets`` var values.

## Prerequisites

The following tools need to be installed on your system prior to deploy VMix:

- AWS Access and Secret Key with permission to create IAM roles(Administrative User);
    - Instructions to create the keys:  
      https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
- AWS CLI;
    - Installation instructions:  
      https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- jq (json processor):
    - Installer: 
      https://stedolan.github.io/jq/download/
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

## Setup

To start, clone this repository using git.  
Then, follow the steps always on the repository root folder.  
If you need help to clone the repository follow this guide:  
https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository

1. Let's create the IAM role that will be used to create the resources.  
   Firstly, get the AWS account ID running the command bellow, and note it somewhere:
    ```bash
    aws sts get-caller-identity | jq -r '.Account'
    ```  

   Create a file ``trust-policy.json`` with the following content replacing ``YOUR-AWS-ACCOUNT-ID`` with the ID informed
   by the command executed previously:
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
        aws iam create-policy --policy-name EC2VmixAccess --policy-document file://policies.json && \
        aws iam attach-role-policy --policy-arn arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:policy/EC2VmixAccess --role-name deploy-vmix-role
    ```

2. Now it's time to configure a profile for AWS CLI using the role.  
   Add to the file ``~/.aws/credentials`` the new role just created as a new profile.  
   Here the ``{YOUR-AWS-ACCOUNT-ID}`` replacement is also necessary, and replace the ``{AWS-REGION}`` to the one desired to
   deploy the resources:
    ```bash
    echo "[vmix]
    role_arn = arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:role/deploy-vmix-role
    source_profile = default
    region = {AWS-REGION}" >> ~/.aws/credentials
    ```

   If your access and secret keys are on another profile than the ``default profile`` change the ``source_profile``
   value above accordingly to the profile with the keys.  
   For more information about using roles with aws cli read it
   here:  https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html

## Deploy

The infrastructure has some variables with default values (such as aws region and instance type) that can be changed
through a .tfvars file.

1. copy the
   `terraform.tfvars.example` file and add it to a `terraform.tfvars` file in the root of the `terraform` folder.
2. You need to input the values for the variables ``cidr``, ``azs``, ``private_subnets``, ``public_subnets``, and ``aws_region``.  
If not ``terraform apply`` will fail.  
Example:
    ```yaml
    cidr = "10.20.0.0/16"

    azs = ["us-west-2a", "us-west-2c"]

    private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

    public_subnets = ["10.20.101.0/24", "10.20.102.0/24"]

    aws_region = "us-west-2"
    ```

<br/>

**To create the infrastructure:**

```bash
cd terraform && \
	terraform init && \
	terraform plan -out=plan.out && \
	terraform apply plan.out
```

to get the instance windows password you can replace the {AWS-PROFILE} variable and run the following command:
```bash
echo "vmix-server-password = $(aws ec2 get-password-data --instance-id $(terraform output vmix_instance_id) --priv-launch-key ./vmix.pem --profile vmix | jq -r '.PasswordData')"
```

<br/>

**To destroy it:**

```bash
terraform plan -destroy -out plan.out && \
    terraform apply plan.out
```

# Remote accessing the machine

To remotely access the Windows machine that will be created on AWS, we will be utilizing
the [Nice DCV software](https://download.nice-dcv.com/) provided
by Amazon. You can download the appropriate client for your operating system and connect to the instance using the
hostname/public IP address, username and password generated by the Terraform output.

# 📺 Streaming remote cameras and desktop

To stream camera and desktop images to the instance we're going to use
the [NDI Tools Software](https://ndi.video/tools/ndi-tools/).

## 🌉 Bridging resources

The best way to share multiple inputs to the running instance is by creating a host-share mechanism using the Bridge
tool.
system from the NDI Tools.

### Starting the host

1. Remote access the instance and start the NDI Tools software
2. Click on the Bridge tool and fill the fields accordingly. Make sure to use the port 5990 (which is the one open on
   security groups, but you can change it on the terraform variables) and to put a strong encryption key.
3. Start the bridge host

### Connecting sources

To connect machines to the remote instance, fire up the NDI Tools on the local machine that you want to join and follow
these steps:

1. Click on the Bridge tool, select the Join tab and fill out the fields based on the host instance
2. Click join

After these steps, you should be able to use your local resources such as camera and desktop screen on the instance. You
can start the NDI tool "Screen capture" to begin sending NDI signals to the instance.
<br/></br>
For more information about the Bridge service, [click here](https://www.youtube.com/watch?v=CkY9kFyOFs8)

## 🔗 Remote share

You can also use the remote share option to be able to send invite URLs to other devices (like mobile smartphones or
even other desktops) to be able to send their NDI sources trough the internet. Just open "Remote" option on NDI
Tools on the AWS instance, enable some remote connections and send the link to the device you want to share.
<br/><br/>
For more information about this service, [click here](https://www.youtube.com/watch?v=wXh-AXwRy30)

# References

https://www.vmix.com/software/  
https://aws.amazon.com/blogs/media/live-video-production-using-vmix-on-amazon-ec2/  
https://docs.aws.amazon.com/dcv/latest/adminguide/what-is-dcv.html  
https://www.bensound.com/  
https://www.pexels.com/videos/

-----
