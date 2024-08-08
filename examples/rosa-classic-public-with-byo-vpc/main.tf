module "rosa" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.3-prerelease.1"

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  machine_cidr           = module.vpc.cidr_block
  create_account_roles   = true
  create_operator_roles  = true
  create_oidc            = true
  aws_subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  aws_availability_zones = module.vpc.availability_zones
  multi_az               = length(module.vpc.availability_zones) > 1
  replicas               = 3
}

############################
# VPC
############################
module "vpc" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/vpc"
  version = "1.6.3-prerelease.1"

  name_prefix        = var.cluster_name
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {
  state = "available"

  # New configuration to exclude Local Zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
