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
