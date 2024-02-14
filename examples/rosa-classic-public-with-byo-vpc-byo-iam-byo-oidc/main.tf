module "rosa" {
  source = "../../"

  cluster_name         = var.cluster_name
  openshift_version    = var.openshift_version
  multi_az             = var.multi_az
  machine_cidr         = var.machine_cidr
  account_role_prefix  = "pub-2-account"
  operator_role_prefix = "pub-2-operator"
  oidc_config_id       = module.oidc_config_and_provider.oidc_config_id # replace with variable once split out properly
  depends_on = [
    module.account_iam_resources # Dependancy can be removed once iam is split out.
  ]
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

### This can be split out into dedicated IAM module ###

module "account_iam_resources" {
  source = "../../modules/account-iam-resources"

  account_role_prefix = "pf-account"
  openshift_version   = "4.14.5"
}

module "operator_policies" {
  source = "../../modules/operator-policies"

  account_role_prefix = "pub-2-account"
  openshift_version   = "4.14.5"
}

module "operator_roles" {
  source = "../../modules/operator-roles"

  operator_role_prefix = "pub-2-operator"
  account_role_prefix  = module.operator_policies.account_role_prefix
  path                 = module.account_iam_resources.path
  oidc_endpoint_url    = module.oidc_config_and_provider.oidc_endpoint_url
  depends_on = [
    module.operator_policies
  ]
}

module "oidc_config_and_provider" {
  source = "../../modules/oidc-config-and-provider"

  managed = true
}
