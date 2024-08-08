module "rosa" {
  source  = "terraform-redhat/rosa-classic/rhcs"
  version = "1.6.3-prerelease.1"

  cluster_name          = var.cluster_name
  openshift_version     = var.openshift_version
  create_account_roles  = true
  create_operator_roles = true
  create_oidc           = true
}

module "machine_pool_1" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/machine-pool"
  version = "1.6.3-prerelease.1"

  cluster_id   = module.rosa.cluster_id
  name         = "pool1"
  machine_type = "r5.xlarge"
  replicas     = 3
}

module "machine_pool_2" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/machine-pool"
  version = "1.6.3-prerelease.1"

  cluster_id   = module.rosa.cluster_id
  name         = "pool2"
  machine_type = "r5.xlarge"
  replicas     = 3
}

module "gitlab_idp" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/idp"
  version = "1.6.3-prerelease.1"

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

module "htpasswd_idp" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/idp"
  version = "1.6.3-prerelease.1"

  cluster_id         = module.rosa.cluster_id
  name               = "htpasswd-idp"
  idp_type           = "htpasswd"
  htpasswd_idp_users = [{ username = "test-user", password = random_password.password.result }]
}

module "github_idp" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/idp"
  version = "1.6.3-prerelease.1"

  cluster_id               = module.rosa.cluster_id
  name                     = "github-idp"
  idp_type                 = "github"
  github_idp_client_id     = random_password.client_id.result     # replace with valid <client-id>
  github_idp_client_secret = random_password.client_secret.result # replace with valid <client-secret>
  github_idp_organizations = ["example"]
}

module "google_idp" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/idp"
  version = "1.6.3-prerelease.1"

  cluster_id               = module.rosa.cluster_id
  name                     = "google-idp"
  idp_type                 = "google"
  google_idp_client_id     = random_password.client_id.result     # replace with valid <client-id>
  google_idp_client_secret = random_password.client_secret.result # replace with valid <client-secret>
  google_idp_hosted_domain = "example.com"
}

module "ldap_idp" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/idp"
  version = "1.6.3-prerelease.1"

  cluster_id        = module.rosa.cluster_id
  name              = "ldap-idp"
  idp_type          = "ldap"
  ldap_idp_ca       = ""
  ldap_idp_url      = "ldap://ldap.forumsys.com/dc=example,dc=com?uid"
  ldap_idp_insecure = true
}

module "openid_idp" {
  source  = "terraform-redhat/rosa-classic/rhcs//modules/idp"
  version = "1.6.3-prerelease.1"

  cluster_id                           = module.rosa.cluster_id
  name                                 = "openid-idp"
  idp_type                             = "openid"
  openid_idp_client_id                 = random_password.client_id.result     # replace with valid <client-id>
  openid_idp_client_secret             = random_password.client_secret.result # replace with valid <client-secret>
  openid_idp_ca                        = ""
  openid_idp_issuer                    = "https://example.com"
  openid_idp_claims_email              = ["example@email.com"]
  openid_idp_claims_groups             = ["example"]
  openid_idp_claims_name               = ["example"]
  openid_idp_claims_preferred_username = ["example"]
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

resource "random_password" "password" {
  length  = 14
  special = true
}
