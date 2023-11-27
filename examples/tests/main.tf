####################################
# Test case 1 - Unmanaged OIDC public cluster

# module "rosa" {
#   source = "../../"

#   create_vpc            = true
#   create_account_roles  = true
#   create_operator_roles = true
#   create_oidc           = true
#   oidc                  = "unmanaged"
#   cluster_name          = "rhcs-pub-1"
#   openshift_version     = "4.13.10"
# }

####################################
# Test case 2 - Managed OIDC public cluster

# module "rosa" {
#   source = "../../"

#   create_vpc            = true
#   create_account_roles  = true
#   create_operator_roles = true
#   create_oidc           = true
#   cluster_name          = "rhcs-pub-2"
#   openshift_version     = "4.13.10"
# }

####################################
# Test case 3 - BYO VPC public cluster

# module "rosa" {
#   source = "../../"

#   create_account_roles    = true
#   create_operator_roles   = true
#   create_oidc             = true
#   cluster_name            = "rhcs-pub-3"
#   openshift_version       = "4.13.10"
#   availability_zones      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
#   vpc_private_subnets_ids = module.vpc.private_subnets
#   vpc_public_subnets_ids  = module.vpc.public_subnets
#   machine_cidr            = "10.66.0.0/16"
#   depends_on = [
#     module.vpc
#   ]
# }

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.1.2"

#   name                 = "rhcs-vpc-3"
#   cidr                 = "10.66.0.0/16"
#   azs                  = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
#   private_subnets      = ["10.66.1.0/24", "10.66.2.0/24", "10.66.3.0/24"]
#   public_subnets       = ["10.66.101.0/24", "10.66.102.0/24", "10.66.103.0/24"]
#   enable_nat_gateway   = true
#   single_nat_gateway   = false
#   enable_dns_hostnames = true
#   enable_dns_support   = true
# }

####################################
# Test case 4 - BYO VPC and IAM roles with custom prefixes. public cluster

module "rosa" {
  source = "../../"

  cluster_name            = "rhcs-pub-3"
  openshift_version       = "4.13.10"
  availability_zones      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  vpc_private_subnets_ids = module.vpc.private_subnets # replace with variable once split out properly
  vpc_public_subnets_ids  = module.vpc.public_subnets  # replace with variable once split out properly
  machine_cidr            = "10.66.0.0/16"
  account_role_prefix     = "pf-account"
  operator_role_prefix    = "pf-operator"
  oidc_config_id          = module.oidc_provider.oidc_config_id # replace with variable once split out properly
  machine_pools = {
    "1" : {
      "name" : "pool1",
      "machine_type" : "r5.xlarge",
      "replicas" : 3
    }
    "2" : {
      "name" : "pool2",
      "machine_type" : "r5.xlarge",
      "replicas" : 3
    }
  }
  depends_on = [
    module.account_iam_resources, # Dependancy can be removed once iam is split out.
    module.vpc
  ]
}

### This can be split out into dedicated IAM module ###

module "account_iam_resources" {
  source = "../../modules/account-iam-resources"

  account_role_prefix = "pf-account"
  ocm_environment     = "production"
  openshift_version   = "4.13.10"
}

module "operator_policies" {
  source = "../../modules/operator-policies"

  account_role_prefix = "pf-account"
  openshift_version   = "4.13.10"
}

module "operator_roles" {
  source = "../../modules/operator-roles"

  operator_role_prefix = "pf-operator"
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

  name                 = "rhcs-vpc-3"
  cidr                 = "10.66.0.0/16"
  azs                  = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets      = ["10.66.1.0/24", "10.66.2.0/24", "10.66.3.0/24"]
  public_subnets       = ["10.66.101.0/24", "10.66.102.0/24", "10.66.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}