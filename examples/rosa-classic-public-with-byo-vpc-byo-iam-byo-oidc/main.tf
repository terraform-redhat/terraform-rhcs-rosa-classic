module "rosa" {
  source = "../../"

  cluster_name            = "rhcs-pub-2"
  openshift_version       = "4.14.5"
  availability_zones      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  vpc_private_subnets_ids = module.vpc.private_subnets # replace with variable once split out properly
  vpc_public_subnets_ids  = module.vpc.public_subnets  # replace with variable once split out properly
  machine_cidr            = "10.66.0.0/16"
  account_role_prefix     = "pub-2-account"
  operator_role_prefix    = "pub-2-operator"
  oidc_config_id          = module.oidc_provider.oidc_config_id # replace with variable once split out properly
  depends_on = [
    module.account_iam_resources # Dependancy can be removed once iam is split out.
  ]
}

### This can be split out into dedicated IAM module ###

module "account_iam_resources" {
  source = "../../modules/account-iam-resources"

  account_role_prefix = "pf-account"
  ocm_environment     = "production"
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
  oidc_endpoint_url    = module.oidc_provider.oidc_endpoint_url
  depends_on = [
    module.operator_policies
  ]
}

module "oidc_provider" {
  source = "../../modules/oidc-provider"

  managed            = true
  secret_arn         = null
  issuer_url         = null
  installer_role_arn = null
}

### This can be split out into dedicated network module ###

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                 = "rhcs-vpc-2"
  cidr                 = "10.66.0.0/16"
  azs                  = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets      = ["10.66.1.0/24", "10.66.2.0/24", "10.66.3.0/24"]
  public_subnets       = ["10.66.101.0/24", "10.66.102.0/24", "10.66.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

