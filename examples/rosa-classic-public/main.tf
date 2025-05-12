module "rosa" {
  source = "../../"

  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  create_admin_user     = true
  path                  = "/tf-example/"
  govcloud              = false
}

