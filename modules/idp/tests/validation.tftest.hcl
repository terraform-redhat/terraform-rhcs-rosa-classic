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
