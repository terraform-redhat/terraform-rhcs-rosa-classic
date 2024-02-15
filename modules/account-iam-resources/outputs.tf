output "account_role_prefix" {
  value       = local.account_role_prefix_valid
  description = "The prefix used for all generated AWS resources."
}

output "openshift_version" {
  value       = var.openshift_version
  description = "The Openshift cluster version of the cluster those account roles are used for."
}

output "account_roles_arn" {
  value       = { for idx, value in time_sleep.account_iam_resources_wait : local.account_roles_properties[idx].role_name => value.triggers["account_iam_role_arn"] }
  description = "List of the Amazon Resource Name (ARN) associated with the AWS IAM roles created"
}

output "path" {
  value       = var.path
  description = "The arn path for the account/operator roles as well as their policies."
}
