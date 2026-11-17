// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "rhcs" {
  mock_resource "rhcs_identity_provider" {
    defaults = {
      id = "idp-mock"
    }
  }
}

run "idp_type_invalid" {
  command = plan

  variables {
    cluster_id = "dummy"
    name       = "dummy"
    idp_type   = "okta"
  }

  expect_failures = [
    var.idp_type
  ]
}

// The run below uses issensitive(), which requires Terraform >= 1.8. The module itself
// still supports the lower required_version in versions.tf; only this test suite needs
// the newer CLI, which the pinned CI Terraform provides.
//
// Do not "simplify" these assertions away: they are the proof that the identity
// provider CA inputs carry a sensitivity mark. Assert on the variables rather than on
// rhcs_identity_provider.*.ca, because the rhcs provider schema marks that attribute
// sensitive on its own and such an assertion would pass even without the module-level
// sensitive = true.
run "idp_ca_inputs_are_sensitive" {
  command = plan

  variables {
    cluster_id               = "dummy"
    name                     = "dummy"
    idp_type                 = "openid"
    openid_idp_ca            = "mock-pem-bundle-not-a-real-certificate"
    openid_idp_client_id     = "dummy"
    openid_idp_client_secret = "dummy"
    openid_idp_issuer        = "https://example.com"
    github_idp_ca            = "mock-pem-bundle-not-a-real-certificate"
    gitlab_idp_ca            = "mock-pem-bundle-not-a-real-certificate"
    ldap_idp_ca              = "mock-pem-bundle-not-a-real-certificate"
  }

  assert {
    condition     = issensitive(var.github_idp_ca)
    error_message = "github_idp_ca must be declared sensitive."
  }

  assert {
    condition     = issensitive(var.gitlab_idp_ca)
    error_message = "gitlab_idp_ca must be declared sensitive."
  }

  assert {
    condition     = issensitive(var.ldap_idp_ca)
    error_message = "ldap_idp_ca must be declared sensitive."
  }

  assert {
    condition     = issensitive(var.openid_idp_ca)
    error_message = "openid_idp_ca must be declared sensitive."
  }

  assert {
    condition     = nonsensitive(rhcs_identity_provider.openid_identity_provider[0].openid.ca) == "mock-pem-bundle-not-a-real-certificate"
    error_message = "openid_idp_ca must still reach the identity provider resource unchanged."
  }
}
