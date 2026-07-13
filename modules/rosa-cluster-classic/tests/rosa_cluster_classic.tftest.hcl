// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "aws" {
  alias = "default"

  mock_data "aws_partition" {
    defaults = {
      dns_suffix         = "amazonaws.com"
      id                 = "aws"
      partition          = "aws"
      reverse_dns_prefix = "amazonaws.com"
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      availability_zone = "us-east-1a"
      id                = "subnet-fake12345"
    }
  }
}

mock_provider "rhcs" {
  alias           = "import_sim"
  override_during = plan

  mock_resource "rhcs_cluster_rosa_classic" {
    defaults = {
      id = "rhcs-fake-classic-cluster-id"
    }
  }
}

variables {
  cluster_name           = "existing-classic-cluster"
  openshift_version      = "4.15.0"
  oidc_config_id         = "00000000000000000000000000000000"
  operator_role_prefix   = "test-operator-prefix"
  account_role_prefix    = "test-account-prefix"
  aws_subnet_ids         = ["subnet-fake12345"]
  aws_availability_zones = ["us-east-1a"]
  aws_account_id         = "123456789012"
  aws_account_arn        = "arn:aws:iam::123456789012:root"
  aws_region             = "us-east-1"
}

run "delete_protection_null" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    delete_protection = null
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.delete_protection == null
    error_message = "delete_protection must be null when unset."
  }
}

run "delete_protection_enabled" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    delete_protection = true
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.delete_protection == true
    error_message = "delete_protection must be true when explicitly enabled."
  }
}

run "delete_protection_disabled" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    delete_protection = false
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.delete_protection == false
    error_message = "delete_protection must be false when explicitly disabled."
  }
}
