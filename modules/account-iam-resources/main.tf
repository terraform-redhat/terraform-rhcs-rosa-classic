# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

locals {
  path                    = coalesce(var.path, "/")
  short_openshift_version = format("%s.%s", split(".", var.openshift_version)[0], split(".", var.openshift_version)[1])
  trust_policy_external_id = (
    var.trust_policy_external_id != null && var.trust_policy_external_id != ""
  ) ? var.trust_policy_external_id : null
  account_roles_properties = [
    {
      role_name            = "Installer"
      role_type            = "installer"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_installer_permission_policy"]
      principal_type       = "AWS"
      principal_identifier = "arn:${data.aws_partition.current.partition}:iam::${data.rhcs_info.current.ocm_aws_account_id}:role/RH-Managed-OpenShift-Installer"
      external_id          = local.trust_policy_external_id
    },
    {
      role_name      = "Support"
      role_type      = "support"
      policy_details = data.rhcs_policies.all_policies.account_role_policies["sts_support_permission_policy"]
      principal_type = "AWS"
      // This is a SRE RH Support role which is used to assume this support role
      principal_identifier = data.rhcs_policies.all_policies.account_role_policies["sts_support_rh_sre_role"]
      external_id          = local.trust_policy_external_id
    },
    {
      role_name            = "Worker"
      role_type            = "instance_worker"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_instance_worker_permission_policy"]
      principal_type       = "Service"
      principal_identifier = "ec2.amazonaws.com"
      external_id          = null
    },
    {
      role_name            = "ControlPlane"
      role_type            = "instance_controlplane"
      policy_details       = data.rhcs_policies.all_policies.account_role_policies["sts_instance_controlplane_permission_policy"]
      principal_type       = "Service"
      principal_identifier = "ec2.amazonaws.com"
      external_id          = null
    }
  ]
  account_roles_count = null_resource.validate_openshift_version != null ? length(local.account_roles_properties) : 0
  # terraform test cannot mock ListNested attributes (items) reliably; fall back to singular item.
  patch_version_list = distinct(concat(
    try([for s in data.rhcs_versions.all_versions.items : s.name], []),
    try([data.rhcs_versions.all_versions.item.name], []),
  ))
  minor_version_list = length(local.patch_version_list) > 0 ? (
    distinct([for s in local.patch_version_list : format("%s.%s", split(".", s)[0], split(".", s)[1])])
    ) : (
    []
  )
  account_role_prefix_valid = (var.account_role_prefix != null && var.account_role_prefix != "") ? (
    var.account_role_prefix
    ) : (
    "account-role-${random_string.default_random[0].result}"
  )
  # Hand-rolled jsonencode instead of aws_iam_policy_document for terraform test compatibility.
  custom_trust_policy_json = [
    for idx in range(local.account_roles_count) : jsonencode({
      Version = "2012-10-17"
      Statement = [
        merge(
          {
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = local.account_roles_properties[idx].principal_type == "AWS" ? {
              AWS = local.account_roles_properties[idx].principal_identifier
              } : {
              Service = local.account_roles_properties[idx].principal_identifier
            }
          },
          local.account_roles_properties[idx].external_id != null ? {
            Condition = {
              StringEquals = {
                "sts:ExternalId" = local.account_roles_properties[idx].external_id
              }
            }
          } : {}
        )
      ]
    })
  ]
}

module "account_iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  # Stay on 5.x: v6.0.0 renames iam-assumable-role → iam-role — https://github.com/terraform-aws-modules/terraform-aws-iam/releases/tag/v6.0.0
  version = ">= 5.60.0, < 6.0.0"

  count = local.account_roles_count

  create_role = true

  role_name = "${local.account_role_prefix_valid}-${local.account_roles_properties[count.index].role_name}-Role"

  role_path                     = local.path
  role_permissions_boundary_arn = var.permissions_boundary

  create_custom_role_trust_policy = true
  custom_role_trust_policy        = local.custom_trust_policy_json[count.index]

  tags = merge(var.tags, {
    red-hat-managed        = true
    rosa_openshift_version = local.short_openshift_version
    rosa_role_prefix       = local.account_role_prefix_valid
    rosa_role_type         = local.account_roles_properties[count.index].role_type
  })
}

module "account_iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  # Stay on 5.x: v6.0.0 breaking submodule/API changes — https://github.com/terraform-aws-modules/terraform-aws-iam/releases/tag/v6.0.0
  version = ">= 5.60.0, < 6.0.0"

  count = local.account_roles_count

  name = "${local.account_role_prefix_valid}-${local.account_roles_properties[count.index].role_name}-Role-Policy"

  policy = local.account_roles_properties[count.index].policy_details
  path   = local.path

  tags = merge(var.tags, {
    rosa_openshift_version = local.short_openshift_version
    rosa_role_prefix       = local.account_role_prefix_valid
    rosa_role_type         = local.account_roles_properties[count.index].role_type
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  count = local.account_roles_count

  role       = module.account_iam_role[count.index].iam_role_name
  policy_arn = module.account_iam_policy[count.index].arn
}

data "rhcs_policies" "all_policies" {}

data "rhcs_versions" "all_versions" {}

resource "random_string" "default_random" {
  count = (var.account_role_prefix != null && var.account_role_prefix != "") ? 0 : 1

  length  = 4
  special = false
  upper   = false
}

data "rhcs_info" "current" {}

resource "null_resource" "validate_openshift_version" {
  lifecycle {
    precondition {
      condition     = contains(local.minor_version_list, local.short_openshift_version)
      error_message = "ERROR: Expected a valid OpenShift version. Valid versions: ${join(", ", local.minor_version_list)}"
    }
  }
}

resource "time_sleep" "account_iam_resources_wait" {
  destroy_duration = "10s"
  create_duration  = "10s"
  triggers = {
    account_iam_role_name    = jsonencode([for value in aws_iam_role_policy_attachment.role_policy_attachment : value.role])
    account_roles_arn        = jsonencode({ for idx, value in module.account_iam_role : local.account_roles_properties[idx].role_name => value.iam_role_arn })
    account_role_prefix      = local.account_role_prefix_valid
    openshift_version        = var.openshift_version
    path                     = var.path
    trust_policy_external_id = local.trust_policy_external_id != null ? local.trust_policy_external_id : ""
  }
}

data "aws_partition" "current" {}
