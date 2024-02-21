module "rosa" {
  source = "../../"

  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
}

module "machine_pool_1" {
  source = "../../modules/machine-pool"

  cluster_id   = module.rosa.cluster_id
  name         = "pool1"
  machine_type = "r5.xlarge"
  replicas     = 3
}

module "machine_pool_2" {
  source = "../../modules/machine-pool"

  cluster_id   = module.rosa.cluster_id
  name         = "pool2"
  machine_type = "r5.xlarge"
  replicas     = 3
}

module "gitlab_idp" {
  source = "../../modules/idp"

  cluster_id = module.rosa.cluster_id
  name       = "gitlab-idp"
  idp_type   = "gitlab"
  # Utilize randomly generated values for "client_id" and "client_secret" to ensure the example configuration:
  # 1. Enables the file to run seamlessly without modifications.
  # 2. Avoid security alerts on "Potential data leak"
  # Please note that these are not real account credentials, and access to the cluster itself is not feasible.
  # To enable GitLab IDP functionality, substitute these random values with valid credentials.
  gitlab_idp_client_id     = random_password.client_id.result     # replace with valid <client-id>
  gitlab_idp_client_secret = random_password.client_secret.result # replace with valid <client-secret>
  gitlab_idp_url           = "https://gitlab.com"
}

resource "random_password" "client_id" {
  length = 16

  numeric = true
  upper   = false
  lower   = false
  special = false
}

resource "random_password" "client_secret" {
  length = 39

  numeric = true
  upper   = true
  lower   = false
  special = false
}
