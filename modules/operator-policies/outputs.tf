# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

output "account_role_prefix" {
  value       = time_sleep.operator_policy_wait.triggers["account_role_prefix"]
  description = "User-defined prefix for all generated AWS resources (default \"account-role-<random>\")"
}
