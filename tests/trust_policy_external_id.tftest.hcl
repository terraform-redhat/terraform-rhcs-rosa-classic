// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:root"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name   = "us-east-1"
      region = "us-east-1"
    }
  }
}

mock_provider "rhcs" {
  mock_data "rhcs_policies" {
    defaults = {
      account_role_policies = {
        sts_installer_permission_policy             = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
        sts_support_permission_policy               = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
        sts_support_rh_sre_role                     = "arn:aws:iam::999999999999:role/RH-SRE-Support"
        sts_instance_worker_permission_policy       = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
        sts_instance_controlplane_permission_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
      }
    }
  }

  mock_data "rhcs_versions" {
    defaults = {
      item = {
        name = "4.14.24"
      }
    }
  }

  mock_data "rhcs_info" {
    defaults = {
      ocm_aws_account_id = "999999999999"
    }
  }

  mock_resource "rhcs_cluster_rosa_classic" {
    defaults = {
      id = "mock-classic-cluster"
    }
  }
}

mock_provider "time" {}
mock_provider "random" {}
mock_provider "null" {}

run "root_passes_external_id_to_account_iam" {
  command = plan

  variables {
    cluster_name             = "test-classic-cluster"
    openshift_version        = "4.14.24"
    oidc_config_id           = "00000000000000000000000000000000"
    aws_subnet_ids           = ["subnet-fake12345"]
    aws_availability_zones   = ["us-east-1a"]
    create_account_roles     = true
    trust_policy_external_id = "test-external-id-12345"
  }

  assert {
    condition     = module.account_iam_resources[0].trust_policy_external_id == "test-external-id-12345"
    error_message = "Root must pass the external ID to account IAM roles."
  }
}

run "root_version_channel_group_fast" {
  command = plan

  variables {
    cluster_name           = "test-classic-cluster"
    openshift_version      = "4.14.24"
    oidc_config_id         = "00000000000000000000000000000000"
    aws_subnet_ids         = ["subnet-fake12345"]
    aws_availability_zones = ["us-east-1a"]
    version_channel_group  = "fast"
  }

  // Reaching this assertion is the proof: main.tf passes version_channel_group
  // straight into module.rosa_cluster_classic, so the run only gets this far when
  // both the root and the submodule validation accept 'fast'. The submodule exposes
  // no channel_group output, and cluster_id is unknown during a mocked plan here,
  // so there is no planned attribute to assert on from the root suite.
  assert {
    condition     = var.version_channel_group == "fast"
    error_message = "The root module must plan successfully with version_channel_group set to 'fast'."
  }
}

// The run below uses issensitive(), which requires Terraform >= 1.8. The module itself
// still supports the lower required_version in versions.tf; only this test suite needs
// the newer CLI, which the pinned CI Terraform provides.
//
// The root module declares its own proxy variables and passes them into
// module.rosa_cluster_classic, so the submodule suite cannot cover these marks: each
// level has a separate variable block. Assert on var.* rather than on a planned
// attribute, because the rhcs provider schema marks the proxy attributes sensitive on
// its own and such an assertion would pass even without the root sensitive = true.
run "root_proxy_inputs_are_sensitive" {
  command = plan

  variables {
    cluster_name            = "test-classic-cluster"
    openshift_version       = "4.14.24"
    oidc_config_id          = "00000000000000000000000000000000"
    aws_subnet_ids          = ["subnet-fake12345"]
    aws_availability_zones  = ["us-east-1a"]
    http_proxy              = "http://proxy.example.com:3128"
    https_proxy             = "https://proxy.example.com:3129"
    no_proxy                = ".example.com"
    additional_trust_bundle = "mock-pem-bundle-not-a-real-certificate"
  }

  assert {
    condition     = issensitive(var.http_proxy)
    error_message = "http_proxy must be declared sensitive in the root module."
  }

  assert {
    condition     = issensitive(var.https_proxy)
    error_message = "https_proxy must be declared sensitive in the root module."
  }

  assert {
    condition     = issensitive(var.additional_trust_bundle)
    error_message = "additional_trust_bundle must be declared sensitive in the root module."
  }

  assert {
    condition     = !issensitive(var.no_proxy)
    error_message = "no_proxy must stay non-sensitive in the root module, matching the rhcs provider schema."
  }
}

run "root_version_channel_group_invalid" {
  command = plan

  variables {
    cluster_name           = "test-classic-cluster"
    openshift_version      = "4.14.24"
    oidc_config_id         = "00000000000000000000000000000000"
    aws_subnet_ids         = ["subnet-fake12345"]
    aws_availability_zones = ["us-east-1a"]
    version_channel_group  = "candidate"
  }

  expect_failures = [var.version_channel_group]
}
