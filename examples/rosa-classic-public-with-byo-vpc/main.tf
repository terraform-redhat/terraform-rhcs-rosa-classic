module "rosa" {
  source = "../../"

  cluster_name            = var.cluster_name
  openshift_version       = var.openshift_version
  multi_az                = var.multi_az
  machine_cidr            = var.machine_cidr
  create_account_roles    = true
  create_operator_roles   = true
  create_oidc             = true
  vpc_public_subnets_ids  = module.vpc.public_subnets
  vpc_private_subnets_ids = module.vpc.private_subnets
  availability_zones      = module.vpc.availability_zones
}

############################
# VPC
############################
module "vpc" {
  source = "../../modules/vpc"

  name_prefix  = var.cluster_name
  subnet_count = var.multi_az ? 3 : 1
  vpc_cidr     = var.machine_cidr
}
