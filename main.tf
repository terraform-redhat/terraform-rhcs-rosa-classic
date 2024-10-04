locals {
  path                 = coalesce(var.path, "/")
  account_role_prefix  = coalesce(var.account_role_prefix, "${var.cluster_name}-account")
  operator_role_prefix = coalesce(var.operator_role_prefix, "${var.cluster_name}-operator")
  sts_roles = {
    installer_role_arn    = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-Installer-Role",
    support_role_arn      = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-Support-Role",
    controlplane_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-ControlPlane-Role",
    worker_role_arn       = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role${local.path}${local.account_role_prefix}-Worker-Role"
  }
  shared_vpc_role_arn = var.private_hosted_zone_role_arn
}

##############################################################
# Account IAM resources: IAM roles and IAM policies
##############################################################
module "account_iam_resources" {
  source = "./modules/account-iam-resources"
  count  = var.create_account_roles ? 1 : 0

  account_role_prefix  = local.account_role_prefix
  openshift_version    = var.openshift_version
  path                 = local.path
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
}

############################
# OIDC config and provider
############################
module "oidc_config_and_provider" {
  source = "./modules/oidc-config-and-provider"
  count  = var.create_oidc ? 1 : 0

  managed = var.managed_oidc
  installer_role_arn = var.managed_oidc ? (
    null
    ) : (
    var.create_account_roles ? (
      module.account_iam_resources[0].account_roles_arn["Installer"]
      ) : (
      local.sts_roles.installer_role_arn
    )
  )
  tags = var.tags
}

############################
# operator policies
############################
module "operator_policies" {
  source = "./modules/operator-policies"
  count  = var.create_operator_roles ? 1 : 0

  account_role_prefix = var.create_account_roles ? (
    module.account_iam_resources[0].account_role_prefix
    ) : (
    local.account_role_prefix
  )
  path                = var.create_account_roles ? module.account_iam_resources[0].path : local.path
  openshift_version   = var.openshift_version
  tags                = var.tags
  shared_vpc_role_arn = local.shared_vpc_role_arn != null ? local.shared_vpc_role_arn : ""
}

############################
# operator roles
############################
module "operator_roles" {
  source = "./modules/operator-roles"
  count  = var.create_operator_roles ? 1 : 0

  operator_role_prefix = local.operator_role_prefix
  account_role_prefix = var.create_account_roles ? (
    module.account_iam_resources[0].account_role_prefix
    ) : (
    local.account_role_prefix
  )
  path                 = var.create_account_roles ? module.account_iam_resources[0].path : local.path
  oidc_endpoint_url    = var.create_oidc ? module.oidc_config_and_provider[0].oidc_endpoint_url : var.oidc_endpoint_url
  depends_on           = [module.operator_policies]
  tags                 = var.tags
  permissions_boundary = var.permissions_boundary
}

############################
# ROSA STS cluster
############################
module "rosa_cluster_classic" {
  source = "./modules/rosa-cluster-classic"

  cluster_name                 = var.cluster_name
  operator_role_prefix         = var.create_operator_roles ? module.operator_roles[0].operator_role_prefix : local.operator_role_prefix
  openshift_version            = var.openshift_version
  path                         = var.create_account_roles ? module.account_iam_resources[0].path : local.path
  installer_role_arn           = var.create_account_roles ? module.account_iam_resources[0].account_roles_arn["Installer"] : local.sts_roles.installer_role_arn
  support_role_arn             = var.create_account_roles ? module.account_iam_resources[0].account_roles_arn["Support"] : local.sts_roles.support_role_arn
  controlplane_role_arn        = var.create_account_roles ? module.account_iam_resources[0].account_roles_arn["ControlPlane"] : local.sts_roles.controlplane_role_arn
  worker_role_arn              = var.create_account_roles ? module.account_iam_resources[0].account_roles_arn["Worker"] : local.sts_roles.worker_role_arn
  oidc_config_id               = var.create_oidc ? module.oidc_config_and_provider[0].oidc_config_id : var.oidc_config_id
  aws_subnet_ids               = var.aws_subnet_ids
  machine_cidr                 = var.machine_cidr
  service_cidr                 = var.service_cidr
  pod_cidr                     = var.pod_cidr
  aws_private_link             = var.aws_private_link
  private                      = var.private
  host_prefix                  = var.host_prefix
  ec2_metadata_http_tokens     = var.ec2_metadata_http_tokens
  tags                         = var.tags
  properties                   = var.properties
  private_hosted_zone_id       = var.private_hosted_zone_id
  private_hosted_zone_role_arn = local.shared_vpc_role_arn
  base_dns_domain              = var.base_dns_domain

  create_admin_user          = var.create_admin_user
  admin_credentials_username = var.admin_credentials_username
  admin_credentials_password = var.admin_credentials_password

  aws_additional_infra_security_group_ids         = var.aws_additional_infra_security_group_ids
  aws_additional_control_plane_security_group_ids = var.aws_additional_control_plane_security_group_ids
  kms_key_arn                                     = var.kms_key_arn

  ########
  # Flags
  ########
  wait_for_create_complete     = var.wait_for_create_complete
  disable_workload_monitoring  = var.disable_workload_monitoring
  disable_scp_checks           = var.disable_scp_checks
  etcd_encryption              = var.etcd_encryption
  fips                         = var.fips
  disable_waiting_in_destroy   = var.disable_waiting_in_destroy
  destroy_timeout              = var.destroy_timeout
  upgrade_acknowledgements_for = var.upgrade_acknowledgements_for
  multi_az                     = var.multi_az

  #######################
  # Default Machine Pool
  #######################
  autoscaling_enabled                       = var.autoscaling_enabled
  replicas                                  = var.replicas
  min_replicas                              = var.min_replicas
  max_replicas                              = var.max_replicas
  compute_machine_type                      = var.compute_machine_type
  worker_disk_size                          = var.worker_disk_size
  default_mp_labels                         = var.default_mp_labels
  aws_availability_zones                    = var.aws_availability_zones
  aws_additional_compute_security_group_ids = var.aws_additional_compute_security_group_ids

  ########
  # Proxy 
  ########
  http_proxy              = var.http_proxy
  https_proxy             = var.https_proxy
  no_proxy                = var.no_proxy
  additional_trust_bundle = var.additional_trust_bundle

  #############
  # Autoscaler 
  #############
  cluster_autoscaler_enabled                  = var.cluster_autoscaler_enabled
  autoscaler_balance_similar_node_groups      = var.autoscaler_balance_similar_node_groups
  autoscaler_skip_nodes_with_local_storage    = var.autoscaler_skip_nodes_with_local_storage
  autoscaler_log_verbosity                    = var.autoscaler_log_verbosity
  autoscaler_max_pod_grace_period             = var.autoscaler_max_pod_grace_period
  autoscaler_pod_priority_threshold           = var.autoscaler_pod_priority_threshold
  autoscaler_ignore_daemonsets_utilization    = var.autoscaler_ignore_daemonsets_utilization
  autoscaler_max_node_provision_time          = var.autoscaler_max_node_provision_time
  autoscaler_balancing_ignored_labels         = var.autoscaler_balancing_ignored_labels
  autoscaler_max_nodes_total                  = var.autoscaler_max_nodes_total
  autoscaler_cores                            = var.autoscaler_cores
  autoscaler_memory                           = var.autoscaler_memory
  autoscaler_gpus                             = var.autoscaler_gpus
  autoscaler_scale_down_enabled               = var.autoscaler_scale_down_enabled
  autoscaler_scale_down_unneeded_time         = var.autoscaler_scale_down_unneeded_time
  autoscaler_scale_down_utilization_threshold = var.autoscaler_scale_down_utilization_threshold
  autoscaler_scale_down_delay_after_add       = var.autoscaler_scale_down_delay_after_add
  autoscaler_scale_down_delay_after_delete    = var.autoscaler_scale_down_delay_after_delete
  autoscaler_scale_down_delay_after_failure   = var.autoscaler_scale_down_delay_after_failure

  ##################
  # default_ingress 
  ##################
  default_ingress_id                               = var.default_ingress_id
  default_ingress_route_selectors                  = var.default_ingress_route_selectors
  default_ingress_excluded_namespaces              = var.default_ingress_excluded_namespaces
  default_ingress_route_wildcard_policy            = var.default_ingress_route_wildcard_policy
  default_ingress_route_namespace_ownership_policy = var.default_ingress_route_namespace_ownership_policy
  default_ingress_cluster_routes_hostname          = var.default_ingress_cluster_routes_hostname
  default_ingress_load_balancer_type               = var.default_ingress_load_balancer_type
  default_ingress_cluster_routes_tls_secret_ref    = var.default_ingress_cluster_routes_tls_secret_ref
}

######################################
# Multiple Machine Pools Generic block
######################################

module "rhcs_machine_pool" {
  source   = "./modules/machine-pool"
  for_each = var.machine_pools

  cluster_id                        = module.rosa_cluster_classic.cluster_id
  name                              = each.value.name
  machine_type                      = each.value.machine_type
  replicas                          = try(each.value.replicas, null)
  use_spot_instances                = try(each.value.use_spot_instances, null)
  max_spot_price                    = try(each.value.max_spot_price, null)
  autoscaling_enabled               = try(each.value.autoscaling_enabled, null)
  min_replicas                      = try(each.value.min_replicas, null)
  max_replicas                      = try(each.value.max_replicas, null)
  taints                            = try(each.value.taints, null)
  labels                            = try(each.value.labels, null)
  multi_availability_zone           = try(each.value.multi_availability_zone, null)
  availability_zone                 = try(each.value.availability_zone, null)
  subnet_id                         = try(each.value.subnet_id, null)
  disk_size                         = try(each.value.disk_size, null)
  aws_additional_security_group_ids = try(each.value.aws_additional_security_group_ids, null)
}

###########################################
# Multiple Identity Providers Generic block
###########################################

module "rhcs_identity_provider" {
  source   = "./modules/idp"
  for_each = var.identity_providers

  cluster_id                            = module.rosa_cluster_classic.cluster_id
  name                                  = each.value.name
  idp_type                              = each.value.idp_type
  mapping_method                        = try(each.value.mapping_method, null)
  github_idp_client_id                  = try(each.value.github_idp_client_id, null)
  github_idp_client_secret              = try(each.value.github_idp_client_secret, null)
  github_idp_ca                         = try(each.value.github_idp_ca, null)
  github_idp_hostname                   = try(each.value.github_idp_hostname, null)
  github_idp_organizations              = try(jsondecode(each.value.github_idp_organizations), null)
  github_idp_teams                      = try(jsondecode(each.value.github_idp_teams), null)
  gitlab_idp_client_id                  = try(each.value.gitlab_idp_client_id, null)
  gitlab_idp_client_secret              = try(each.value.gitlab_idp_client_secret, null)
  gitlab_idp_url                        = try(each.value.gitlab_idp_url, null)
  gitlab_idp_ca                         = try(each.value.gitlab_idp_ca, null)
  google_idp_client_id                  = try(each.value.google_idp_client_id, null)
  google_idp_client_secret              = try(each.value.google_idp_client_secret, null)
  google_idp_hosted_domain              = try(each.value.google_idp_hosted_domain, null)
  htpasswd_idp_users                    = try(jsondecode(each.value.htpasswd_idp_users), null)
  ldap_idp_bind_dn                      = try(each.value.ldap_idp_bind_dn, null)
  ldap_idp_bind_password                = try(each.value.ldap_idp_bind_password, null)
  ldap_idp_ca                           = try(each.value.ldap_idp_ca, null)
  ldap_idp_insecure                     = try(each.value.ldap_idp_insecure, null)
  ldap_idp_url                          = try(each.value.ldap_idp_url, null)
  ldap_idp_emails                       = try(jsondecode(each.value.ldap_idp_emails), null)
  ldap_idp_ids                          = try(jsondecode(each.value.ldap_idp_ids), null)
  ldap_idp_names                        = try(jsondecode(each.value.ldap_idp_names), null)
  ldap_idp_preferred_usernames          = try(jsondecode(each.value.ldap_idp_preferred_usernames), null)
  openid_idp_ca                         = try(each.value.openid_idp_ca, null)
  openid_idp_claims_email               = try(jsondecode(each.value.openid_idp_claims_email), null)
  openid_idp_claims_groups              = try(jsondecode(each.value.openid_idp_claims_groups), null)
  openid_idp_claims_name                = try(jsondecode(each.value.openid_idp_claims_name), null)
  openid_idp_claims_preferred_username  = try(jsondecode(each.value.openid_idp_claims_preferred_username), null)
  openid_idp_client_id                  = try(each.value.openid_idp_client_id, null)
  openid_idp_client_secret              = try(each.value.openid_idp_client_secret, null)
  openid_idp_extra_scopes               = try(jsondecode(each.value.openid_idp_extra_scopes), null)
  openid_idp_extra_authorize_parameters = try(jsondecode(each.value.openid_idp_extra_authorize_parameters), null)
  openid_idp_issuer                     = try(each.value.openid_idp_issuer, null)
}

resource "null_resource" "validations" {
  lifecycle {
    precondition {
      condition     = (var.create_operator_roles == true && var.create_oidc != true && var.oidc_endpoint_url == null) == false
      error_message = "\"oidc_endpoint_url\" mustn't be empty when oidc is pre-created (create_oidc != true)."
    }
    precondition {
      condition     = (var.create_oidc != true && var.oidc_config_id == null) == false
      error_message = "\"oidc_config_id\" mustn't be empty when oidc is pre-created (create_oidc != true)."
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
