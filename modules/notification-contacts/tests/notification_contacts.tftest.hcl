// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "rhcs" {}

variables {
  cluster_id = "mock-classic-cluster"
  contacts   = ["ocm-user-1", "ocm-user-2"]
}

run "contacts_set_correctly" {
  command = plan

  assert {
    condition     = rhcs_cluster_notification_contacts.contacts.cluster_id == "mock-classic-cluster"
    error_message = "cluster_id must be passed through to the notification contacts resource."
  }

  assert {
    condition     = length(rhcs_cluster_notification_contacts.contacts.contacts) == 2
    error_message = "contacts must contain the expected number of entries."
  }

  assert {
    condition     = contains(rhcs_cluster_notification_contacts.contacts.contacts, "ocm-user-1")
    error_message = "contacts must include ocm-user-1."
  }

  assert {
    condition     = contains(rhcs_cluster_notification_contacts.contacts.contacts, "ocm-user-2")
    error_message = "contacts must include ocm-user-2."
  }
}

run "single_contact" {
  command = plan

  variables {
    contacts = ["single-user"]
  }

  assert {
    condition     = length(rhcs_cluster_notification_contacts.contacts.contacts) == 1
    error_message = "contacts must contain exactly one entry when a single contact is provided."
  }

  assert {
    condition     = contains(rhcs_cluster_notification_contacts.contacts.contacts, "single-user")
    error_message = "contacts must include the single contact."
  }
}
