output "account_role_prefix" {
  value       = time_sleep.operator_policy_wait.triggers["account_role_prefix"]
  description = "User-defined prefix for all generated AWS resources (default \"account-role-<random>\")"
}
