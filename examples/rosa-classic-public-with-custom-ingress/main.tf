# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

module "rosa" {
  source = "../../"

  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  create_admin_user     = true
  govcloud              = false

  version_channel_group    = "stable"
  domain_prefix            = "mycluster"
  trust_policy_external_id = "example-external-id"
  oidc_prefix              = "myoidc"

  default_ingress_component_routes = {
    oauth = {
      hostname       = "oauth.example.com"
      tls_secret_ref = "oauth-tls-secret"
    }
    console = {
      tls_secret_ref = "console-tls-secret"
      hostname       = "console.example.com"
    }
    downloads = {
      hostname       = "downloads.example.com"
      tls_secret_ref = "downloads-tls-secret"
    }
  }

  machine_pools = {
    pool1 = {
      name         = "pool1"
      machine_type = "m5.xlarge"
      replicas     = 2
      labels       = { "environment" = "example" }
      aws_tags     = { "project" = "example", "team" = "platform" }
    }
  }

}
