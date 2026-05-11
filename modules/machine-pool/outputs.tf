# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

output "id" {
  value       = rhcs_machine_pool.machine_pool.id
  description = "Unique identifier of the machine pool."
}
