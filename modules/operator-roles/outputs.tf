output "operator_role_prefix" {
  value = time_sleep.role_resources_propagation.triggers["operator_role_prefix"]
}

output "operator_roles_arn" {
  value = { for idx, val in aws_iam_role.operator_role : data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[idx].operator_namespace => val.arn }
}
