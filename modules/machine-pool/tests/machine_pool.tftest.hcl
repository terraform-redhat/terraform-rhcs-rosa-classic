// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "rhcs" {}

variables {
  cluster_id   = "mock-classic-cluster"
  name         = "test-pool"
  machine_type = "m5.xlarge"
}

run "aws_tags_and_ignore_deletion_error_enabled" {
  command = plan

  variables {
    aws_tags              = { project = "rosa", team = "platform" }
    ignore_deletion_error = true
  }

  assert {
    condition     = length(rhcs_machine_pool.machine_pool.aws_tags) == 2 && rhcs_machine_pool.machine_pool.aws_tags["project"] == "rosa" && rhcs_machine_pool.machine_pool.aws_tags["team"] == "platform"
    error_message = "AWS tags must reach the RHCS machine pool resource."
  }

  assert {
    condition     = rhcs_machine_pool.machine_pool.ignore_deletion_error == true
    error_message = "ignore_deletion_error must be enabled on the RHCS machine pool resource."
  }
}

run "ignore_deletion_error_disabled" {
  command = plan

  variables {
    ignore_deletion_error = false
  }

  assert {
    condition     = rhcs_machine_pool.machine_pool.ignore_deletion_error == false
    error_message = "ignore_deletion_error must remain disabled when set to false."
  }
}
