locals {
  short_openshift_version             = format("%s.%s", split(".", var.openshift_version)[0], split(".", var.openshift_version)[1])
  shared_vpc_role_arn_replace         = "%%{shared_vpc_role_arn}"
  openshift_ingress_policy            = data.rhcs_policies.all_policies.operator_role_policies["openshift_ingress_operator_cloud_credentials_policy"]
  shared_vpc_openshift_ingress_policy = replace(data.rhcs_policies.all_policies.operator_role_policies["shared_vpc_openshift_ingress_operator_cloud_credentials_policy"], local.shared_vpc_role_arn_replace, var.shared_vpc_role_arn)

  operator_roles_policy_properties = [
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-cloud-network-config-controller-cloud-credentials", 0, 64)
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_cloud_network_config_controller_cloud_credentials_policy"]
      namespace      = "openshift-cloud-network-config-controller"
      operator_name  = "cloud-credentials"
    },
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-machine-api-aws-cloud-credentials", 0, 64)
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_machine_api_aws_cloud_credentials_policy"]
      namespace      = "openshift-machine-api"
      operator_name  = "aws-cloud-credentials"
    },
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-cloud-credential-operator-cloud-credential-operator-iam-ro-creds", 0, 64)
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_cloud_credential_operator_cloud_credential_operator_iam_ro_creds_policy"]
      namespace      = "openshift-cloud-credential-operator"
      operator_name  = "cloud-credential-operator-iam-ro-creds"
    },
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-image-registry-installer-cloud-credentials", 0, 64)
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_image_registry_installer_cloud_credentials_policy"]
      namespace      = "openshift-image-registry"
      operator_name  = "installer-cloud-credentials"
    },
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-ingress-operator-cloud-credentials", 0, 64)
      policy_details = var.shared_vpc_role_arn == "" ? local.openshift_ingress_policy : local.shared_vpc_openshift_ingress_policy
      namespace      = "openshift-ingress-operator"
      operator_name  = "cloud-credentials"
    },
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-cluster-csi-drivers-ebs-cloud-credentials", 0, 64)
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_cluster_csi_drivers_ebs_cloud_credentials_policy"]
      namespace      = "openshift-cluster-csi-drivers"
      operator_name  = "ebs-cloud-credentials"
  }]
  patch_version_list = [for s in data.rhcs_versions.all_versions.items : s.name]
  minor_version_list = length(local.patch_version_list) > 0 ? (
    distinct([for s in local.patch_version_list : format("%s.%s", split(".", s)[0], split(".", s)[1])])
    ) : (
    []
  )
}

resource "aws_iam_policy" "operator-policy" {
  count = null_resource.validate_openshift_version != null ? length(local.operator_roles_policy_properties) : 0

  name   = local.operator_roles_policy_properties[count.index].policy_name
  policy = local.operator_roles_policy_properties[count.index].policy_details

  tags = merge(var.tags, {
    rosa_openshift_version = local.short_openshift_version
    rosa_role_prefix       = var.account_role_prefix
    operator_namespace     = local.operator_roles_policy_properties[count.index].namespace
    operator_name          = local.operator_roles_policy_properties[count.index].operator_name
  })
}

data "rhcs_policies" "all_policies" {}

# This resource is used in order to avoid operator-policy destruction
# before it was detached from the roles
resource "time_sleep" "operator_policy_wait" {
  destroy_duration = "10s"

  triggers = {
    account_role_prefix  = var.account_role_prefix
    operator_policy_arns = "[ ${join(", ", aws_iam_policy.operator-policy[*].arn)} ]"
  }
}

resource "null_resource" "validate_openshift_version" {
  lifecycle {
    precondition {
      condition     = contains(local.minor_version_list, local.short_openshift_version)
      error_message = "ERROR: Expected a valid OpenShift version. Valid versions: ${join(", ", local.minor_version_list)}"
    }
  }
}

data "rhcs_versions" "all_versions" {}
