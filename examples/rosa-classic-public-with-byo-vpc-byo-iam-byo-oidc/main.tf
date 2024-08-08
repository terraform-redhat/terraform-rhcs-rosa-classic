locals {
  account_role_prefix  = "${var.cluster_name}-account"
  operator_role_prefix = "${var.cluster_name}-operator"
}

module "rosa" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.3-prerelease.1"

  cluster_name           = var.cluster_name
  openshift_version      = var.openshift_version
  account_role_prefix    = module.account_iam_resources.account_role_prefix
  operator_role_prefix   = module.operator_roles.operator_role_prefix
  oidc_config_id         = module.oidc_config_and_provider.oidc_config_id # replace with variable once split out properly
  machine_cidr           = module.vpc.cidr_block
  aws_subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  aws_availability_zones = module.vpc.availability_zones
  multi_az               = length(module.vpc.availability_zones) > 1
  path                   = module.account_iam_resources.path
  replicas               = 3
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

### This can be split out into dedicated IAM module ###

module "account_iam_resources" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/account-iam-resources"
  version = "1.6.3-prerelease.1"

  account_role_prefix = local.account_role_prefix
  openshift_version   = "4.14.5"
  path                = "/tf-example/"
}

module "operator_policies" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/operator-policies"
  version = "1.6.3-prerelease.1"

  account_role_prefix = local.account_role_prefix
  openshift_version   = "4.14.5"
  path                = module.account_iam_resources.path
}

module "operator_roles" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/operator-roles"
  version = "1.6.3-prerelease.1"

  operator_role_prefix = local.operator_role_prefix
  account_role_prefix  = module.operator_policies.account_role_prefix
  path                 = module.account_iam_resources.path
  oidc_endpoint_url    = module.oidc_config_and_provider.oidc_endpoint_url
}

module "oidc_config_and_provider" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/oidc-config-and-provider"
  version = "1.6.3-prerelease.1"

  managed = true
}
