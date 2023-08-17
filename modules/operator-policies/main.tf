resource "time_sleep" "wait_10_seconds" {
  destroy_duration = "10s"
}

locals {
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
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_ingress_operator_cloud_credentials_policy"]
      namespace      = "openshift-ingress-operator"
      operator_name  = "cloud-credentials"
    },
    {
      policy_name    = substr("${var.account_role_prefix}-openshift-cluster-csi-drivers-ebs-cloud-credentials", 0, 64)
      policy_details = data.rhcs_policies.all_policies.operator_role_policies["openshift_cluster_csi_drivers_ebs_cloud_credentials_policy"]
      namespace      = "openshift-cluster-csi-drivers"
      operator_name  = "ebs-cloud-credentials"
  }]
}

resource "aws_iam_policy" "operator-policy" {
  count = length(local.operator_roles_policy_properties)

  name   = local.operator_roles_policy_properties[count.index].policy_name
  policy = local.operator_roles_policy_properties[count.index].policy_details

  tags = merge(var.tags, {
    rosa_openshift_version = "${var.openshift_version}"
    rosa_role_prefix       = "${var.account_role_prefix}"
    operator_namespace     = "${local.operator_roles_policy_properties[count.index].namespace}"
    operator_name          = "${local.operator_roles_policy_properties[count.index].operator_name}"
  })
}

data "rhcs_policies" "all_policies" {}
