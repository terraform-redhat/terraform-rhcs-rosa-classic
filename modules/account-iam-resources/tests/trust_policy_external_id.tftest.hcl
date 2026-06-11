// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "aws" {
  alias = "default"

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn  = "arn:aws:iam::123456789012:role/mock"
      id   = "mock-role-id"
      name = "mock-role"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/mock"
      id  = "mock-policy-id"
    }
  }

  mock_resource "aws_iam_role_policy_attachment" {
    defaults = {
      id = "mock-attachment-id"
    }
  }
}

mock_provider "rhcs" {
  alias = "default"

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

  # rhcs_versions.items is ListNested (Plugin Framework); terraform test cannot mock
  # list-of-object attributes reliably (tuple vs object coercion). Mock item instead;
  # main.tf patch_version_list falls back to item.name when items is empty.
  mock_data "rhcs_versions" {
    defaults = {
      item = {
        available_channels = ["stable-4.14"]
        id                 = "openshift-v4.14.24"
        name               = "4.14.24"
      }
    }
  }

  mock_data "rhcs_info" {
    defaults = {
      ocm_aws_account_id = "999999999999"
    }
  }
}

mock_provider "time" {
  alias = "default"

  mock_resource "time_sleep" {
    defaults = {
      id = "mock-sleep"
    }
  }
}

mock_provider "random" {
  alias = "default"
}

mock_provider "null" {
  alias = "default"

  mock_resource "null_resource" {
    defaults = {
      id = "mock-null"
    }
  }
}

variables {
  account_role_prefix = "tf-test-acc"
  openshift_version   = "4.14.24"
}

run "null_external_id_omits_condition" {
  command = plan

  providers = {
    aws    = aws.default
    rhcs   = rhcs.default
    time   = time.default
    random = random.default
    null   = null.default
  }

  variables {
    trust_policy_external_id = null
  }

  assert {
    condition     = !strcontains(local.custom_trust_policy_json[0], "sts:ExternalId")
    error_message = "Installer trust policy must not include sts:ExternalId when trust_policy_external_id is null."
  }

  assert {
    condition     = !strcontains(local.custom_trust_policy_json[1], "sts:ExternalId")
    error_message = "Support trust policy must not include sts:ExternalId when trust_policy_external_id is null."
  }
}

run "empty_external_id_rejected" {
  command = plan

  providers = {
    aws    = aws.default
    rhcs   = rhcs.default
    time   = time.default
    random = random.default
    null   = null.default
  }

  variables {
    trust_policy_external_id = ""
  }

  expect_failures = [
    var.trust_policy_external_id,
  ]
}

run "whitespace_external_id_rejected" {
  command = plan

  providers = {
    aws    = aws.default
    rhcs   = rhcs.default
    time   = time.default
    random = random.default
    null   = null.default
  }

  variables {
    trust_policy_external_id = "   "
  }

  expect_failures = [
    var.trust_policy_external_id,
  ]
}

run "non_empty_external_id_adds_condition_to_installer_and_support" {
  command = plan

  providers = {
    aws    = aws.default
    rhcs   = rhcs.default
    time   = time.default
    random = random.default
    null   = null.default
  }

  variables {
    trust_policy_external_id = "test-external-id-12345"
  }

  assert {
    condition = strcontains(
      local.custom_trust_policy_json[0],
      "test-external-id-12345",
    )
    error_message = "Installer trust policy must include the configured external ID."
  }

  assert {
    condition = strcontains(
      local.custom_trust_policy_json[1],
      "test-external-id-12345",
    )
    error_message = "Support trust policy must include the configured external ID."
  }

  assert {
    condition = strcontains(
      local.custom_trust_policy_json[0],
      "sts:ExternalId",
    )
    error_message = "Installer trust policy must include sts:ExternalId condition key."
  }

  assert {
    condition = strcontains(
      local.custom_trust_policy_json[1],
      "sts:ExternalId",
    )
    error_message = "Support trust policy must include sts:ExternalId condition key."
  }
}

run "worker_and_control_plane_never_include_external_id" {
  command = plan

  providers = {
    aws    = aws.default
    rhcs   = rhcs.default
    time   = time.default
    random = random.default
    null   = null.default
  }

  variables {
    trust_policy_external_id = "test-external-id-12345"
  }

  assert {
    condition     = !strcontains(local.custom_trust_policy_json[2], "sts:ExternalId")
    error_message = "Worker trust policy must never include sts:ExternalId."
  }

  assert {
    condition     = !strcontains(local.custom_trust_policy_json[3], "sts:ExternalId")
    error_message = "Control plane trust policy must never include sts:ExternalId."
  }

  assert {
    condition     = strcontains(local.custom_trust_policy_json[2], "ec2.amazonaws.com")
    error_message = "Worker role trust policy must trust ec2.amazonaws.com."
  }

  assert {
    condition     = strcontains(local.custom_trust_policy_json[3], "ec2.amazonaws.com")
    error_message = "Control plane role trust policy must trust ec2.amazonaws.com."
  }

  assert {
    condition     = length(module.account_iam_role) == 4
    error_message = "account_iam_role module must create Installer, Support, Worker, and ControlPlane roles."
  }
}
