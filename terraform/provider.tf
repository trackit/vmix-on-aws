provider "aws" {
  region  = var.region
  profile = "vmix"
  # allowed_account_ids = var.allowed_account_ids
}