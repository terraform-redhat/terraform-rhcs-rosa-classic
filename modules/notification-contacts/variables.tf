# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

// Required
variable "cluster_id" {
  description = "Identifier of the cluster."
  type        = string
}

// Required
variable "contacts" {
  description = "Set of OCM account usernames to receive cluster notification emails. This set is authoritative — the full set of contacts is managed by this resource."
  type        = set(string)
}
