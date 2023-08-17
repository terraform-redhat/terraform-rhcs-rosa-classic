module "account_iam_resources" {
  source = "../../modules/account-iam-resources"

  account_role_prefix = "${var.cluster_name}-account"
  ocm_environment     = var.ocm_environment
  openshift_version   = var.openshift_version
}

module "operator_policies" {
  source = "../../modules/operator-policies"

  account_role_prefix = module.account_iam_resources.account_role_prefix
  openshift_version   = module.account_iam_resources.openshift_version
}

module "unmanaged_oidc_config" {
  source = "../../modules/unmanaged-oidc-config"
}

module "oidc_provider" {
  source = "../../modules/oidc-provider"

  managed            = false
  secret_arn         = module.unmanaged_oidc_config.secret_arn
  issuer_url         = module.unmanaged_oidc_config.issuer_url
  installer_role_arn = module.account_iam_resources.account_roles_arn["Installer"]
}

module "operator_roles" {
  source = "../../modules/operator-roles"

  operator_role_prefix = "${var.cluster_name}-operator"
  account_role_prefix  = module.account_iam_resources.account_role_prefix
  path                 = module.account_iam_resources.path
  oidc_endpoint_url    = module.oidc_provider.oidc_endpoint_url
}

// module "vpc_private" {
//   source = "../../modules/vpc-private"
// 
//   name = "${var.cluster_name}-vpc"
// }

module "rosa_cluster_classic" {
  source = "../../modules/rosa-cluster-classic"

  cluster_name          = var.cluster_name
  operator_role_prefix  = module.operator_roles.operator_role_prefix
  openshift_version     = var.openshift_version
  replicas              = 3
  installer_role_arn    = module.account_iam_resources.account_roles_arn["Installer"]
  support_role_arn      = module.account_iam_resources.account_roles_arn["Support"]
  controlplane_role_arn = module.account_iam_resources.account_roles_arn["ControlPlane"]
  worker_role_arn       = module.account_iam_resources.account_roles_arn["Worker"]
  oidc_config_id        = module.oidc_provider.oidc_config_id
  //subnets               = module.vpc_private.private_subnets
  //availability_zones    = module.vpc_private.availability_zones
  //aws_private_link      = true
  //private               = true
  multi_az = true
}
