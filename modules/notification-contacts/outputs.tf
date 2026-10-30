# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

output "contacts" {
  value       = rhcs_cluster_notification_contacts.contacts.contacts
  description = "Set of OCM account usernames configured as notification contacts for the cluster."
}
