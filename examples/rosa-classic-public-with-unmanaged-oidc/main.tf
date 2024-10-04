module "rosa" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.4-prerelease.2"

  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  managed_oidc          = false
}
