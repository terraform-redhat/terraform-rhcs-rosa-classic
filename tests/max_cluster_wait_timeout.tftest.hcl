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

run "root_max_cluster_wait_timeout_unset_passthrough" {
  command = apply

  variables {
    cluster_name                        = "test-classic-cluster"
    openshift_version                   = "4.14.24"
    oidc_config_id                      = "00000000000000000000000000000000"
    aws_subnet_ids                      = ["subnet-fake12345"]
    aws_availability_zones              = ["us-east-1a"]
    wait_for_create_complete            = true
    max_cluster_wait_timeout_in_minutes = null
  }

  # Terraform test cannot address a child module's internal resource
  # (module.rosa_cluster_classic exposes only its declared outputs, not
  # rhcs_cluster_rosa_classic.rosa_classic_cluster). The resource-attribute
  # passthrough is asserted directly in the submodule suite
  # (modules/rosa-cluster-classic/tests/rosa_cluster_classic.tftest.hcl).
  # Here we assert the un-indexed module instance plans successfully with the
  # variable supplied, proving the root wires it through without error.
  assert {
    condition     = module.rosa_cluster_classic.cluster_id == "mock-classic-cluster"
    error_message = "Root must plan the un-indexed rosa_cluster_classic module when max_cluster_wait_timeout_in_minutes is unset."
  }
}

run "root_max_cluster_wait_timeout_set_passthrough" {
  command = apply

  variables {
    cluster_name                        = "test-classic-cluster"
    openshift_version                   = "4.14.24"
    oidc_config_id                      = "00000000000000000000000000000000"
    aws_subnet_ids                      = ["subnet-fake12345"]
    aws_availability_zones              = ["us-east-1a"]
    wait_for_create_complete            = true
    max_cluster_wait_timeout_in_minutes = 90
  }

  # See the comment in the unset run: child-module internal resources are not
  # addressable from a root test; the numeric passthrough (== 90) is asserted
  # in the submodule suite. Here we confirm the un-indexed module plans with a
  # set timeout value.
  assert {
    condition     = module.rosa_cluster_classic.cluster_id == "mock-classic-cluster"
    error_message = "Root must plan the un-indexed rosa_cluster_classic module when max_cluster_wait_timeout_in_minutes is set."
  }
}

run "root_max_cluster_wait_timeout_no_effect_branch" {
  command = apply

  variables {
    cluster_name                        = "test-classic-cluster"
    openshift_version                   = "4.14.24"
    oidc_config_id                      = "00000000000000000000000000000000"
    aws_subnet_ids                      = ["subnet-fake12345"]
    aws_availability_zones              = ["us-east-1a"]
    wait_for_create_complete            = false
    max_cluster_wait_timeout_in_minutes = 90
  }

  # See the comment in the unset run: child-module internal resources are not
  # addressable from a root test; the no-effect-branch passthrough (== 90 with
  # wait_for_create_complete = false) is asserted in the submodule suite. Here
  # we confirm the un-indexed module plans in the waiter-off branch.
  assert {
    condition     = module.rosa_cluster_classic.cluster_id == "mock-classic-cluster"
    error_message = "Root must plan the un-indexed rosa_cluster_classic module when wait_for_create_complete is false."
  }
}
