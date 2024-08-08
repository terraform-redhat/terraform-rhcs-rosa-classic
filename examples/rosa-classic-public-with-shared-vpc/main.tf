provider "aws" {
  alias = "shared-vpc"

  access_key               = var.shared_vpc_aws_access_key_id
  secret_key               = var.shared_vpc_aws_secret_access_key
  region                   = data.aws_region.current.name
  profile                  = var.shared_vpc_aws_profile
  shared_credentials_files = var.shared_vpc_aws_shared_credentials_files
}

locals {
  account_role_prefix          = "${var.cluster_name}-account"
  operator_role_prefix         = "${var.cluster_name}-operator"
  shared_resources_name_prefix = var.cluster_name
  shared_vpc_role_name         = "${local.shared_resources_name_prefix}-shared-vpc-role"
}

data "aws_region" "current" {}

############################
# VPC
############################
module "vpc" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/vpc"
  version = "1.6.3-prerelease.1"

  providers = {
    aws = aws.shared-vpc
  }

  name_prefix              = local.shared_resources_name_prefix
  availability_zones_count = 3
}

##############################################################
# Account roles includes IAM roles and IAM policies
##############################################################
module "account_iam_resources" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/account-iam-resources"
  version = "1.6.3-prerelease.1"

  account_role_prefix = local.account_role_prefix
  openshift_version   = var.openshift_version
}

data "aws_caller_identity" "shared_vpc" {
  provider = aws.shared-vpc
}

############################
# operator policies
############################
module "operator_policies" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/operator-policies"
  version = "1.6.3-prerelease.1"

  account_role_prefix = module.account_iam_resources.account_role_prefix
  openshift_version   = module.account_iam_resources.openshift_version
  shared_vpc_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.shared_vpc.account_id}:role/${local.shared_vpc_role_name}"
  path                = module.account_iam_resources.path
}

############################
# OIDC provider
############################
module "oidc_config_and_provider" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/oidc-config-and-provider"
  version = "1.6.3-prerelease.1"

  managed = true
}

############################
# operator roles
############################
module "operator_roles" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/operator-roles"
  version = "1.6.3-prerelease.1"

  operator_role_prefix = local.operator_role_prefix

  account_role_prefix = module.operator_policies.account_role_prefix
  path                = module.account_iam_resources.path
  oidc_endpoint_url   = module.oidc_config_and_provider.oidc_endpoint_url
}

resource "rhcs_dns_domain" "dns_domain" {}

############################
# shared-vpc-policy-and-hosted-zone
############################
data "aws_caller_identity" "current" {}

module "shared-vpc-policy-and-hosted-zone" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/shared-vpc-policy-and-hosted-zone"
  version = "1.6.3-prerelease.1"

  providers = {
    aws = aws.shared-vpc
  }

  cluster_name              = var.cluster_name
  name_prefix               = local.shared_resources_name_prefix
  target_aws_account        = data.aws_caller_identity.current.account_id
  installer_role_arn        = module.account_iam_resources.account_roles_arn["Installer"]
  ingress_operator_role_arn = module.operator_roles.operator_roles_arn["openshift-ingress-operator"]
  subnets                   = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  hosted_zone_base_domain   = rhcs_dns_domain.dns_domain.id
  vpc_id                    = module.vpc.vpc_id
}

############################
# ROSA STS cluster
############################
module "rosa_cluster_classic" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/rosa-cluster-classic"
  version = "1.6.3-prerelease.1"

  cluster_name                 = var.cluster_name
  operator_role_prefix         = module.operator_roles.operator_role_prefix
  account_role_prefix          = module.account_iam_resources.account_role_prefix
  openshift_version            = var.openshift_version
  oidc_config_id               = module.oidc_config_and_provider.oidc_config_id
  aws_subnet_ids               = module.shared-vpc-policy-and-hosted-zone.shared_subnets
  multi_az                     = length(module.vpc.availability_zones) > 1
  replicas                     = 3
  admin_credentials_username   = "kubeadmin"
  admin_credentials_password   = random_password.password.result
  base_dns_domain              = rhcs_dns_domain.dns_domain.id
  private_hosted_zone_id       = module.shared-vpc-policy-and-hosted-zone.hosted_zone_id
  private_hosted_zone_role_arn = module.shared-vpc-policy-and-hosted-zone.shared_role
}

resource "random_password" "password" {
  length  = 14
  special = true
}

locals {
  shared_vpc_aws_credentials_provided = length(var.shared_vpc_aws_access_key_id) > 0 && length(var.shared_vpc_aws_secret_access_key) > 0
  shared_vpc_aws_profile_provided     = length(var.shared_vpc_aws_profile) > 0
}

resource "null_resource" "validations" {
  lifecycle {
    precondition {
      condition     = (local.shared_vpc_aws_credentials_provided == false && local.shared_vpc_aws_profile_provided == false) == false
      error_message = "AWS credentials for the shared-vpc account must be provided. This can provided with \"var.shared_vpc_aws_access_key_id\" and \"var.shared_vpc_aws_secret_access_key\" or with existing profile \"var.shared_vpc_aws_profile\""
    }
  }
}

data "aws_partition" "current" {}
