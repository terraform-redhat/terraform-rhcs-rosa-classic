
module "rosa" {
  source = "../../"

  create_vpc            = true
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
  cluster_name          = "rhcs-pub-3"
  openshift_version     = "4.14.5"
  machine_pools = {
    "1" : {
      "name" : "pool1",
      "machine_type" : "r5.xlarge",
      "replicas" : 3
    }
    "2" : {
      "name" : "pool2",
      "machine_type" : "r5.xlarge",
      "replicas" : 3
    }
  }
  idp = {
    "1" : {
      "name" : "idp1",
      "gitlab" = {
        "client_id"     = "2189835314857134"
        "client_secret" = "DG66575SKFGMdDFDSDSGTFSB47634735VDSFFDV"
        "url"           = "https://gitlab.com"
      }
    }
  }
}
