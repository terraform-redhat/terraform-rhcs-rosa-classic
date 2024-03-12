locals {
  path           = coalesce(var.path, "/")
  aws_account_id = var.aws_account_id == null ? data.aws_caller_identity.current[0].account_id : var.aws_account_id
  sts_roles = {
    role_arn = var.installer_role_arn != null ? (
      var.installer_role_arn
      ) : (
      "arn:${data.aws_partition.current[0].partition}:iam::${local.aws_account_id}:role${local.path}${var.account_role_prefix}-Installer-Role"
    ),
    support_role_arn = var.support_role_arn != null ? (
      var.support_role_arn
      ) : (
      "arn:${data.aws_partition.current[0].partition}:iam::${local.aws_account_id}:role${local.path}${var.account_role_prefix}-Support-Role"
    ),
    instance_iam_roles = {
      master_role_arn = var.controlplane_role_arn != null ? (
        var.controlplane_role_arn
        ) : (
        "arn:${data.aws_partition.current[0].partition}:iam::${local.aws_account_id}:role${local.path}${var.account_role_prefix}-ControlPlane-Role"
      ),
      worker_role_arn = var.worker_role_arn != null ? (
        var.worker_role_arn
        ) : (
        "arn:${data.aws_partition.current[0].partition}:iam::${local.aws_account_id}:role${local.path}${var.account_role_prefix}-Worker-Role"
      ),
    },
    operator_role_prefix = var.operator_role_prefix,
    oidc_config_id       = var.oidc_config_id
  }
  aws_account_arn = var.aws_account_arn == null ? data.aws_caller_identity.current[0].arn : var.aws_account_arn
  admin_credentials = var.admin_credentials_username == null && var.admin_credentials_password == null ? (
    null
    ) : (
    { username = var.admin_credentials_username, password = var.admin_credentials_password }
  )
}

resource "rhcs_cluster_rosa_classic" "rosa_classic_cluster" {
  name           = var.cluster_name
  cloud_region   = var.aws_region == null ? data.aws_region.current[0].name : var.aws_region
  aws_account_id = local.aws_account_id
  replicas       = var.replicas
  version        = var.openshift_version
  sts            = local.sts_roles
  aws_subnet_ids = var.aws_subnet_ids
  availability_zones = length(var.aws_availability_zones) > 0 ? (
    var.aws_availability_zones
    ) : (
    length(var.aws_subnet_ids) > 0 ? (
      distinct(data.aws_subnet.provided_subnet[*].availability_zone)
      ) : (
      slice(data.aws_availability_zones.available[0].names, 0, var.multi_az == true ? 3 : 1)
    )
  )
  multi_az             = var.multi_az
  admin_credentials    = local.admin_credentials
  autoscaling_enabled  = var.autoscaling_enabled
  base_dns_domain      = var.base_dns_domain
  compute_machine_type = var.compute_machine_type
  worker_disk_size     = var.worker_disk_size
  min_replicas         = var.min_replicas
  max_replicas         = var.max_replicas
  machine_cidr         = var.machine_cidr
  service_cidr         = var.service_cidr
  pod_cidr             = var.pod_cidr
  host_prefix          = var.host_prefix
  default_mp_labels    = var.default_mp_labels
  private_hosted_zone = var.private_hosted_zone_id == null ? null : {
    id       = var.private_hosted_zone_id
    role_arn = var.private_hosted_zone_role_arn
  }
  private          = var.private
  aws_private_link = var.aws_private_link
  proxy = var.http_proxy != null || var.https_proxy != null || var.no_proxy != null || var.additional_trust_bundle != null ? (
    {
      http_proxy              = var.http_proxy
      https_proxy             = var.https_proxy
      no_proxy                = var.no_proxy
      additional_trust_bundle = var.additional_trust_bundle
    }
    ) : (
    null
  )
  ec2_metadata_http_tokens = var.ec2_metadata_http_tokens

  properties = merge(
    {
      rosa_creator_arn = local.aws_account_arn
    },
    var.properties
  )
  tags = var.tags

  aws_additional_compute_security_group_ids       = var.aws_additional_compute_security_group_ids
  aws_additional_infra_security_group_ids         = var.aws_additional_infra_security_group_ids
  aws_additional_control_plane_security_group_ids = var.aws_additional_control_plane_security_group_ids

  kms_key_arn                  = var.kms_key_arn
  wait_for_create_complete     = var.wait_for_create_complete
  disable_scp_checks           = var.disable_scp_checks
  disable_workload_monitoring  = var.disable_workload_monitoring
  etcd_encryption              = var.etcd_encryption
  fips                         = var.fips
  disable_waiting_in_destroy   = var.disable_waiting_in_destroy
  destroy_timeout              = var.destroy_timeout
  upgrade_acknowledgements_for = var.upgrade_acknowledgements_for

  lifecycle {
    precondition {
      condition = (
        !(var.installer_role_arn != null && var.support_role_arn != null && var.controlplane_role_arn != null && var.worker_role_arn != null)
        &&
        var.account_role_prefix == null
      ) == false
      error_message = "Either provide the \"account_role_prefix\" or specify all ARNs for account roles (\"installer_role_arn\", \"support_role_arn\", \"controlplane_role_arn\", \"worker_role_arn\")."
    }
    precondition {
      condition = (
        var.installer_role_arn != null && var.support_role_arn != null && var.controlplane_role_arn != null &&
        var.worker_role_arn != null && var.account_role_prefix != null
      ) == false
      error_message = "The \"account_role_prefix\" shouldn't be provided when all ARNs for account roles are specified (\"installer_role_arn\", \"support_role_arn\", \"controlplane_role_arn\", \"worker_role_arn\")."
    }
    precondition {
      condition = (
        (
          var.autoscaler_balance_similar_node_groups != null || var.autoscaler_skip_nodes_with_local_storage != null ||
          var.autoscaler_log_verbosity != null || var.autoscaler_max_pod_grace_period != null ||
          var.autoscaler_pod_priority_threshold != null || var.autoscaler_ignore_daemonsets_utilization != null ||
          var.autoscaler_max_node_provision_time != null || var.autoscaler_balancing_ignored_labels != null ||
          var.autoscaler_max_nodes_total != null || var.autoscaler_cores != null || var.autoscaler_memory != null ||
          var.autoscaler_gpus != null || var.autoscaler_scale_down_enabled != null ||
          var.autoscaler_scale_down_unneeded_time != null || var.autoscaler_scale_down_utilization_threshold != null ||
          var.autoscaler_scale_down_delay_after_add != null || var.autoscaler_scale_down_delay_after_delete != null ||
          var.autoscaler_scale_down_delay_after_failure != null
        )
        && var.cluster_autoscaler_enabled != true
      ) == false
      error_message = "Autoscaler parameters cannot be modified while the cluster autoscaler is disabled. Please ensure that cluster_autoscaler_enabled variable is set to true"
    }
  }
}

resource "rhcs_cluster_autoscaler" "cluster_autoscaler" {
  count = var.cluster_autoscaler_enabled == true ? 1 : 0

  cluster                       = rhcs_cluster_rosa_classic.rosa_classic_cluster.id
  balance_similar_node_groups   = var.autoscaler_balance_similar_node_groups
  skip_nodes_with_local_storage = var.autoscaler_skip_nodes_with_local_storage
  log_verbosity                 = var.autoscaler_log_verbosity
  max_pod_grace_period          = var.autoscaler_max_pod_grace_period
  pod_priority_threshold        = var.autoscaler_pod_priority_threshold
  ignore_daemonsets_utilization = var.autoscaler_ignore_daemonsets_utilization
  max_node_provision_time       = var.autoscaler_max_node_provision_time
  balancing_ignored_labels      = var.autoscaler_balancing_ignored_labels

  resource_limits = {
    max_nodes_total = var.autoscaler_max_nodes_total
    cores           = var.autoscaler_cores
    memory          = var.autoscaler_memory
    gpus            = var.autoscaler_gpus
  }

  scale_down = {
    enabled               = var.autoscaler_scale_down_enabled
    unneeded_time         = var.autoscaler_scale_down_unneeded_time
    utilization_threshold = var.autoscaler_scale_down_utilization_threshold
    delay_after_add       = var.autoscaler_scale_down_delay_after_add
    delay_after_delete    = var.autoscaler_scale_down_delay_after_delete
    delay_after_failure   = var.autoscaler_scale_down_delay_after_failure
  }
}

resource "rhcs_default_ingress" "default_ingress" {
  cluster                          = rhcs_cluster_rosa_classic.rosa_classic_cluster.id
  id                               = var.default_ingress_id
  route_selectors                  = var.default_ingress_route_selectors
  excluded_namespaces              = var.default_ingress_excluded_namespaces
  route_wildcard_policy            = var.default_ingress_route_wildcard_policy
  route_namespace_ownership_policy = var.default_ingress_route_namespace_ownership_policy
  cluster_routes_hostname          = var.default_ingress_cluster_routes_hostname
  load_balancer_type               = var.default_ingress_load_balancer_type
  cluster_routes_tls_secret_ref    = var.default_ingress_cluster_routes_tls_secret_ref
}

data "aws_caller_identity" "current" {
  count = var.aws_account_id == null || var.aws_account_arn == null ? 1 : 0
}

data "aws_region" "current" {
  count = var.aws_region == null ? 1 : 0
}

data "aws_availability_zones" "available" {
  count = length(var.aws_availability_zones) > 0 ? 0 : 1

  state = "available"

  # New configuration to exclude Local Zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_subnet" "provided_subnet" {
  count = length(var.aws_availability_zones) > 0 ? 0 : length(var.aws_subnet_ids)

  id = var.aws_subnet_ids[count.index]
}

data "aws_partition" "current" {
  count = var.account_role_prefix == null ? 0 : 1
}
