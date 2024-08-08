module "rosa" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.3-prerelease.1"

  cluster_name               = var.cluster_name
  openshift_version          = var.openshift_version
  create_account_roles       = true
  create_operator_roles      = true
  create_oidc                = true
  path                       = "/tf-example/"
  managed_oidc               = false
  aws_private_link           = true
  private                    = true
  autoscaling_enabled        = true
  min_replicas               = 3
  max_replicas               = 6
  machine_cidr               = module.vpc.cidr_block
  aws_subnet_ids             = module.vpc.private_subnets
  aws_availability_zones     = module.vpc.availability_zones
  multi_az                   = length(module.vpc.availability_zones) > 1
  cluster_autoscaler_enabled = true
  autoscaler_log_verbosity   = 4
}

############################
# VPC
############################
module "vpc" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/vpc"
  version = "1.6.3-prerelease.1"

  name_prefix              = var.cluster_name
  availability_zones_count = 3
}

