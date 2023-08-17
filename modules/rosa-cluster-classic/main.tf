data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  sts_roles = {
    role_arn         = var.installer_role_arn,
    support_role_arn = var.support_role_arn,
    instance_iam_roles = {
      master_role_arn = var.controlplane_role_arn,
      worker_role_arn = var.worker_role_arn
    },
    operator_role_prefix = var.operator_role_prefix,
    oidc_config_id       = var.oidc_config_id
  }
}

resource "rhcs_cluster_rosa_classic" "rosa_sts_cluster" {
  name           = var.cluster_name
  cloud_region   = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
  replicas       = var.replicas
  version        = var.openshift_version
  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }
  sts            = local.sts_roles
  aws_subnet_ids = var.subnets
  // availability_zones = var.availability_zones
  // aws_private_link   = var.aws_private_link
  // private            = var.private
  multi_az = var.multi_az
}

resource "rhcs_cluster_wait" "rosa_cluster" {
  cluster = rhcs_cluster_rosa_classic.rosa_sts_cluster.id
  # timeout in minutes
  timeout = 60
}
