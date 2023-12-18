module "rosa" {
  source = "../../"

  create_vpc            = true
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  oidc                  = "unmanaged"
  cluster_name          = "rhcs-pub-5"
  openshift_version     = "4.14.5"
}
