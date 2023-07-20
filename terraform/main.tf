module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  reuse_nat_ips          = true             # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids    = aws_eip.nat.*.id # <= IPs specified here as input to the module
  #   enable_vpn_gateway = true

  #   Enable Public access to RDS instances
  #   create_database_subnet_group           = true
  #   create_database_subnet_route_table     = true
  #   create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# This S3 bucket will not be created unless var.create_bucket is set to true
# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   create_bucket = var.create_bucket

#   bucket = var.bucket_name
#   force_destroy       = "true"
#   acl    = "private"

#   control_object_ownership = true
#   object_ownership         = "ObjectWriter"

#   versioning = {
#     enabled = true
#   }
# }

# module to create API that control Media Live, Media Package
module "medialive_api" {
  count                = var.input_security_group != "" ? 1 : 0
  source               = "github.com/trackit/aws-workflow-live-streaming?ref=no-provider"
  region               = var.aws_region
  lambda_zip_path      = "./medialive_api.zip"
  archive_bucket_name  = var.media_live_bucket_name
  input_security_group = var.input_security_group
}

# resource "aws_media_convert_queue" "vmix" {
#   name = "vmix-vod-queue"
# }

module "mediaconvert_flow" {
  count                 = var.input_security_group != "" ? 1 : 0
  source                = "github.com/trackit/aws-workflow-video-on-demand?ref=no-provider"
  region                = var.aws_region
  input_bucket_name     = var.media_live_bucket_name
  output_bucket_name    = var.media_convert_input_bucket_name
  lambda_zip_path       = "./mediaconvert_lambda.zip"
  project_base_name     = "vmix_vod"
  bucket_event_prefix   = "input/"
  bucket_event_suffix   = ".mov"
  mediaconvert_endpoint = var.media_convert_endpoint
}

resource "aws_eip" "nat" {
  # count = 2 # Because will be using only one NAT Gateway

  count = length(var.private_subnets)

  vpc = true

  tags = {
    Name = var.name
  }
}