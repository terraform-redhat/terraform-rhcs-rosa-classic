module "rosa" {
  source = "../../"

  create_vpc            = true
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  cluster_name          = "rhcs-pub-1"
  openshift_version     = "4.13.10"
}

