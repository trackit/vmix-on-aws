variable "allowed_account_ids" {
  description = "List of allowed AWS account ids where resources can be created"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "us-west-1"
}

variable "aws_profile" {
  description = "Local profile to use with aws cli"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "vmix"
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "g4dn.2xlarge"
}

variable "ami" {
  description = "The EC2 instance AMI"
  type        = string
  default     = "ami-05e6d59d866d538f0"
}
