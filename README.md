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
      <li><a href="#prerequisites">Prerequisites</a></li>
      <li><a href="#architecture-diagram">Architecture Diagram</a></li>
      <li><a href="#setup">Setup</a></li>
      <li><a href="#deployment">Deployment</a></li>
      <li><a href="#advanced-deployment-live-streaming-and-vod-integration">Advanced Deployment</a></li>
        <ul>
          <li><a href="#live-streaming-configuration">Live Streaming Configuration</a></li>
            <ul>
              <li><a href="#create-start-stop-and-delete-media-live-channel">Manage Media Live Channel</a></li>
            </ul>
          <li><a href="#video-on-demand-configuration">Video On Demand Configuration</a></li>
        </ul>
        <li><a href="#destroy-the-deployment">Destroy the deployment</a></li>
    </li>
    <li><a href="#remote-accessing-the-instance">Remote accessing the vMix Instance</a></li>
    <li><a href="#-streaming-remote-cameras-and-desktop">Streaming Remote Devices</a></li>
    <li><a href="#references">References</a></li>
  </ol>
</details>
<br/>

# Getting started

This guide provides step-by-step instructions for deploying a vMix environment utilizing Terraform infrastructure as code.  
vMix is a professional live video production and streaming software that allows users to mix multiple video sources, apply transitions and effects, add graphics, and stream live to various platforms.  
It serves as a versatile and feature-rich live video production software, facilitating the creation of professional live productions. 

To learn more about vMix, visit their official website: https://www.vmix.com/software/.  

Also check this [video](https://www.youtube.com/watch?v=IiLbqxYj_DI) about the vMix and the infrastructure discussed here.

**By following this guide, you will set up the following resources and applications with default configurations:**

## Network

- 1 Virtual Private Cloud (VPC)
- 2 Public Subnets
- 2 Private Subnets
- 2 NAT Gateways
- 2 Elastic IP Addresses
- 1 Security Group

## IAM

- Roles
- Policies

## EC2 Instance Provisioning

- 1 Private Key
- 1 AWS Key Pair
- 1 EC2 instance of type **g4dn.2xlarge**, including the following software components:
  - Nice DCV
  - NVIDIA GRID Driver
  - NDI
  - vMix
  - Sample Audio/Video files

## Elemental Resources Configuration

- AWS Elemental MediaLive
- AWS Elemental MediaPackage
- AWS Elemental MediaConvert

## Serverless Resources Integration

- API Gateway
- Lambda Functions

## Additional Resources

- S3 Bucket
- DynamoDB

## Optional Additions

- CloudFront Integration

*The number of subnets will depend on your infrastructure needs. This guide assumes 2 subnets are sufficient, but you can adjust the `private_subnets` and `public_subnets` variable values to your requirements.

# Prerequisites

Before deploying vMix on AWS using Terraform, ensure that you have the following tools and permissions in place:

- AWS Access and Secret Key with permissions to create IAM roles (Administrative User):
  - Instructions to create the keys can be found [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey).
- AWS CLI:
  - Installation instructions are available [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- jq (json processor):
  - Installation: [Download jq](https://stedolan.github.io/jq/download/).
- Git:
  - Installation instructions can be found [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
- Terraform:
  - Installation instructions are available [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
- Nice DCV Client:
  - Installation: [Download Nice DCV Client](https://download.nice-dcv.com/).

Additionally, ensure you have the `zip` tool installed. You can find installation instructions for various Linux distributions [here](https://www.tecmint.com/install-zip-and-unzip-in-linux/).

If you don't have an Administrative user yet, apart from the root user, you can follow this guide to create one:  
[Creating an AWS SSO User](https://docs.aws.amazon.com/singlesignon/latest/userguide/getting-started.html).  

# Architecture Diagram

![Infrastructure](./arch.png)

# Setup

To begin, follow these steps within the root folder of the cloned repository.

If you require assistance with cloning the repository, refer to this guide:  
[Cloning a Repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)

1. **IAM Role Creation**

    Start by creating the necessary IAM role for resource creation.  
    Execute the following commands and make sure to replace `{YOUR-AWS-ACCOUNT-ID}` with the AWS account ID retrieved from the command below:

    ```bash
    aws sts get-caller-identity | jq -r '.Account'
    ```

    Create a file named `trust-policy.json` with the following content, replacing `{YOUR-AWS-ACCOUNT-ID}`:

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

    Run the following commands, ensuring you replace `{YOUR-AWS-ACCOUNT-ID}`:

    ```bash
    aws iam create-role --role-name deploy-vmix-role --assume-role-policy-document file://trust-policy.json && \
        aws iam create-policy --policy-name EC2VmixAccess --policy-document file://policies.json && \
        aws iam attach-role-policy --policy-arn arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:policy/EC2VmixAccess --role-name deploy-vmix-role
    ```

2. **AWS CLI Profile Configuration**

    Configure an AWS CLI profile using the newly created role.  
    Add the following details to the `~/.aws/credentials` file.  
    Replace `{YOUR-AWS-ACCOUNT-ID}` and `{AWS-REGION}` as necessary:

    ```bash
    echo "[vmix]
    role_arn = arn:aws:iam::{YOUR-AWS-ACCOUNT-ID}:role/deploy-vmix-role
    source_profile = default
    region = {AWS-REGION}" >> ~/.aws/credentials
    ```

    If your access and secret keys are stored in a profile other than the `default` profile, adjust the `source_profile` value accordingly. For more details about using roles with AWS CLI, refer to this guide: [AWS CLI Configure Role](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html)

# Deployment

The following steps will guide you through deploying the infrastructure. Some variables have default values, such as the AWS region and instance type, which can be customized using a .tfvars file.

1. **Configuration File Setup**

    - Rename the `terraform.tfvars.example` file to `terraform.tfvars`.
    - Modify the variable values in the `terraform.tfvars` file according to your preferences. These variables are essential and must not be left empty (except for `instance_type`).

    Example `terraform.tfvars` content:
    ```yaml
    cidr = "10.20.0.0/16"

    azs = ["us-west-2a", "us-west-2c"]

    private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

    public_subnets = ["10.20.101.0/24", "10.20.102.0/24"]

    aws_region = "us-west-2"
    ```

2. **Infrastructure Creation**

    Navigate to the repository root folder and execute the following commands:

    ```bash
    cd terraform && \
        terraform init && \
        terraform plan -out=plan.out && \
        terraform apply plan.out
    ```

    To obtain the Windows instance password, replace `{YOUR-AWS-REGION}` and execute the command below:

    ```bash
    aws ec2 get-password-data --instance-id $(terraform output vmix_instance_id | sed 's/"//g') --priv-launch-key ./vmix.pem --profile vmix --region {YOUR-AWS-REGION} | jq -r '.PasswordData'
    ```

3. **Infrastructure Destruction**

    To dismantle the infrastructure, run the following command:

    ```bash
    terraform plan -destroy -out plan.out && \
        terraform apply plan.out
    ```

*Note: Ensure that you exercise caution when destroying the infrastructure, as this action is irreversible and will remove all resources.*

Bellow there's a section explaining how to access the Instance and basic configure vMix:  
<a href="#remote-accessing-the-instance">Remote accessing the vMix Instance</a>

# Advanced Deployment: Live Streaming and VOD Integration

This section guides you through the steps to integrate vMix with AWS Live Streaming and Video On Demand (VOD) solutions, utilizing two Terraform modules developed by TrackIt:

- **Live Streaming**: [AWS Workflow Live Streaming](https://github.com/trackit/aws-workflow-live-streaming)
- **Video On Demand**: [AWS Workflow Video On Demand](https://github.com/trackit/aws-workflow-video-on-demand)

## Live Streaming Configuration

For the Live Streaming setup, the deployment encompasses the following resources:
- API Gateway resources
- DynamoDB
- Lambda Functions (for controlling AWS Media Live and AWS Media Package)

1. **Media Live Input Security Group**  

    Before proceeding with Terraform, ensure you have a MediaLive Input Security Group. To create one with an open rule for everyone, use the following command, replacing `{YOUR-AWS-REGION}` with your desired region:

    ```bash
    aws medialive create-input-security-group --region {YOUR-AWS-REGION} --whitelist-rules Cidr=0.0.0.0/0 | jq -r '.SecurityGroup.Id'
    ```

    Make note of the generated Input Security Group ID. To remove it later, use the command:

    ```bash
    aws medialive delete-input-security-group --region {YOUR-AWS-REGION} --input-security-group-id {YOUR-INPUT-SECGROUP-ID}
    ```

2. **Lambda Controlling Code**  

    Additionally, you need to create the required code files for the API responsible for controlling AWS Media Live and AWS Media Package. Execute the following commands from the root repository:

    ```bash
    mkdir live-streaming-api && \
      cd live-streaming-api && \
      curl https://codeload.github.com/trackit/aws-workflow-live-streaming/tar.gz/master | \
      tar -xz --strip=2 aws-workflow-live-streaming-master/live-streaming-api && \
      zip -r ../terraform/medialive_api.zip .
    ```

3. **Deploy Resources with Terraform**  

    Finally, run Terraform to deploy the resources. Terraform will create an S3 bucket to store the MediaLive and MediaPackage files. Assign a unique name to the bucket using the `media_live_bucket_name` variable.  
    Replace `{YOUR-INPUT-SECGROUP-ID}` with the Input Security Group ID created earlier, and provide a desired name for the `media_live_bucket_name`:

    ```bash
    cd terraform && \
      terraform init && \
      terraform plan \
      -var="input_security_group={YOUR-INPUT-SECGROUP-ID}" \
      -var="create_bucket=true" \
      -var="media_live_bucket_name={DESIRED-MEDIA-LIVE-BUCKET-NAME}" \
      -out=plan.out && \
      terraform apply plan.out
    ```

    Upon completion of the `terraform apply` process, you'll receive the API endpoint required to initiate the Media Live Channel. The endpoint URL, formed by the API ID, will be displayed in the Terraform output:

    ```bash
    medialive_api = [
      {
        "apigateway_url" = "https://d8hlcql80j.execute-api.us-west-2.amazonaws.com/dev"
      },
    ]
    ```

    Retain this URL as it will be necessary for subsequent steps.

    If you intend to distribute your live stream and VOD content using CloudFront, modify the command by setting the `using_cloudfront` variable to true and specifying your AWS CloudFront domain in the `cloudfront_live_domain` variable:
      ```bash
        cd terraform && \
          terraform init && \
          terraform plan \
          -var="input_security_group={YOUR-INPUT-SECGROUP-ID}" \
          -var="create_bucket=true" \
          -var="media_live_bucket_name={DESIRED-MEDIA-LIVE-BUCKET-NAME}" \
          -var="using_cloudfront=true" \
          -var="cloudfront_live_domain={YOUR-CLOUDFRONT-DOMAIN}" \
          -out=plan.out && \
          terraform apply plan.out
        ```

### Create, Start, Stop, and Delete Media Live Channel

The provided API should be used to manage livestreams. It does not require authorization.  
A Postman collection is available in the module repository [here](https://github.com/trackit/aws-workflow-live-streaming/blob/master/postman_collection.json).

You will need to make API requests to start, stop, and delete the stream on AWS Media Live. These actions are executed through a Lambda integrated with an API Gateway.

For comprehensive instructions, refer to: [Getting Started with API](https://github.com/trackit/aws-workflow-live-streaming#get-started-with-api)


## Video On Demand Configuration

In the Video On Demand (VOD) deployment, all live streaming files are converted into the VOD format (.mp4).

The deployment encompasses the following resources:
- S3 Bucket resources  
- Lambda Functions (for creating the Media Convert jobs when triggered by the s3 bucket)

To perform the VOD deployment, follow these steps:

1. **Obtain the MediaConvert Endpoint**

    Retrieve the MediaConvert endpoint for the AWS Account you are using with the following command:

    ```bash
    aws mediaconvert describe-endpoints --region {YOUR-AWS-REGION}
    ```

    Make note of the output, as it will be needed for running Terraform.

2. **Zip the Required Files for Lambda VOD Workflow**

    From the repository root folder, execute the following commands:

    ```bash
    mkdir vod-workflow && \
      cd vod-workflow && \
      curl https://codeload.github.com/trackit/aws-workflow-video-on-demand/tar.gz/master | \
      tar -xz --strip=2 aws-workflow-video-on-demand-master/mediaconvert_lambda && \
      zip -r ../terraform/mediaconvert_lambda.zip .
    ```

3. **Initiate the Terraform Deployment**

    To kick off the VOD deployment, execute the following Terraform command:

    ```bash
    terraform plan \
      -var="input_security_group={YOUR-INPUT-SECGROUP-ID}" \
      -var="create_bucket=true" \
      -var="media_live_bucket_name={DESIRED-MEDIA-LIVE-BUCKET-NAME}" \
      -var="media_convert_bucket_name={DESIRED-MEDIA-CONVERT-BUCKET-NAME}" \
      -var="media_convert_endpoint={YOUR-MEDIA-CONVERT-ENDPOINT}" \
      -out=plan.out && \
      terraform apply plan.out
    ```

     Similarly, if you aim to distribute your live stream and VOD content through CloudFront, modify the command by setting the `using_cloudfront` variable to true and indicating your AWS CloudFront domain in the `cloudfront_live_domain` variable:

    ```bash
    terraform plan \
      -var="input_security_group={YOUR-INPUT-SECGROUP-ID}" \
      -var="create_bucket=true" \
      -var="media_live_bucket_name={DESIRED-MEDIA-LIVE-BUCKET-NAME}" \
      -var="media_convert_bucket_name={DESIRED-MEDIA-CONVERT-BUCKET-NAME}" \
      -var="media_convert_endpoint={YOUR-MEDIA-CONVERT-ENDPOINT}" \
      -var="using_cloudfront=true" \
      -var="cloudfront_live_domain={YOUR-CLOUDFRONT-DOMAIN}" \
      -out=plan.out && \
      terraform apply plan.out
    ```

    Upon the successful execution of the terraform apply command, the live streaming deployment, coupled with the VOD setup, is completed. This deployment also takes into account CloudFront distribution if it is applicable to your configuration.

# Destroy the deployment

If you find it necessary to dismantle the deployment, you can achieve this in just a few minutes using various methods, including the API created, Terraform, and the AWS CLI.
1. **Delete Elemental Resources**  
    First and foremost, it's vital to halt the Media Live Channel and subsequently delete the channel. This can be executed through the AWS Management Console or by utilizing the API (via POST and DELETE requests), as thoroughly outlined in the documentation:  
    [Get Started with API](https://github.com/trackit/aws-workflow-live-streaming#get-started-with-api)

2. **Delete Terraform Resources**  
    Once the Media Live and Media Package components have been successfully dismantled, proceed with the removal of resources created by Terraform. Make sure to execute the following commands from within the Terraform folder:
    ```bash
    terraform plan -destroy -out plan.out && \
      terraform apply plan.out
    ```

3. **Delete IAM Resources**  
    Upon completing the preceding steps, move forward to eliminate the established role and policy. An effective approach involves navigating to the AWS IAM Management Console's Role Menu ([console.aws.amazon.com/iamv2/home#/roles](https://console.aws.amazon.com/iamv2/home#/roles)) and searching for the role named "deploy-vmix-role."  
    Access this role and proceed to remove the permission policy that was associated with it.  
    Be attentive to any warning prompts. Subsequently, delete the role itself.

4. **Delete Media Live Input Security Group**  
    The final step involves the Input Security Group that was created manually using the AWS CLI. Execute the following command, replacing `{YOUR-INPUT-SECGROUP-ID}` with the Input Security Group ID that was generated at the beginning:
    ```bash
    aws medialive delete-input-security-group --region {YOUR-AWS-REGION} --input-security-group-id {YOUR-INPUT-SECGROUP-ID}
    ```

With these actions completed, your deployment will be successfully dismantled.

# Remote Accessing the Instance

To establish remote access to the Windows machine created on AWS, we will utilize the [Nice DCV software](https://download.nice-dcv.com/) provided by Amazon.  
Download the appropriate client for your operating system and connect to the instance using the hostname/public IP address, username, and password generated by the Terraform output.  

Upon logging in to the instance, you will find a vMix shortcut on the desktop.  
When you launch vMix for the first time, you might receive a notification that the key has expired.  
In this scenario, you will need to generate a trial key for yourself within the application or by visiting the vMix website. Alternatively, you can choose to purchase the full version of vMix if desired.

# 📺 Streaming Remote Cameras and Desktop

To stream camera and desktop images to the instance, we will employ the [NDI Tools Software](https://ndi.video/tools/ndi-tools/).

## 🌉 Bridging resources

The best way to share multiple inputs to the running instance is by creating a host-share mechanism using the Bridge
tool.
system from the NDI Tools.

## Starting the host

1. Remote access the instance and start the NDI Tools software
2. Click on the Bridge tool and fill the fields accordingly. Make sure to use the port 5990 (which is the one open on
   security groups, but you can change it on the terraform variables) and to put a strong encryption key.
3. Start the bridge host

## Connecting sources

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
