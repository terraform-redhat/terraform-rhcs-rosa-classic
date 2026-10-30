# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

// Required
variable "cluster_id" {
  description = "Identifier of the cluster."
  type        = string
}

// Required
variable "contacts" {
  description = "Set of OCM account usernames to receive cluster notification emails. Values must be OCM usernames, not email addresses — using email addresses can cause persistent plan diffs and may lead to incorrect contact removal. All contacts must belong to the same Red Hat organization as the cluster. This set is authoritative — the full set of contacts is managed by this resource."
  type        = set(string)
}
