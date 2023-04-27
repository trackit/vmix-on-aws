module "network" {
  source = "./modules/network"
  version = "~> 3.0"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}