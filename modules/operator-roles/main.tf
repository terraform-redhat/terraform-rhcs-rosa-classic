locals {
  operator_roles_count = (var.govcloud == true) ? 7 : 6
  operator_role_prefix = (var.operator_role_prefix != null && var.operator_role_prefix != "") ? var.operator_role_prefix : var.account_role_prefix
  path                 = coalesce(var.path, "/")
}

resource "aws_iam_role" "operator_role" {
  count = local.operator_roles_count

  name                 = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].role_name
  path                 = local.path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = data.aws_iam_policy_document.custom_trust_policy[count.index].json

  tags = merge(var.tags, {
    red-hat-managed    = true
    operator_namespace = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_namespace
    operator_name      = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_name
  })
}

resource "aws_iam_role_policy_attachment" "operator_role_policy_attachment" {
  count = local.operator_roles_count

  role       = aws_iam_role.operator_role[count.index].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy${local.path}${data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].policy_name}"
}

data "aws_iam_policy_document" "custom_trust_policy" {
  count = local.operator_roles_count

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_endpoint_url}"]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "${var.oidc_endpoint_url}:sub"
      values   = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].service_accounts
    }
  }
}

data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = local.operator_role_prefix
  account_role_prefix  = var.account_role_prefix

  lifecycle {
    # The operator_iam_roles should contains 6 elements (or 7 for GovCloud installations)
    postcondition {
      condition     = length(self.operator_iam_roles) == local.operator_roles_count
      error_message = "The operator roles list returned has a length of ${length(self.operator_iam_roles)}, which differs from the expected value of ${local.operator_roles_count}. To solve this, you need to update \"local.operator_roles_count\" value to ${length(self.operator_iam_roles)} and apply again."
    }
  }
}

data "aws_caller_identity" "current" {}

# Wait 20 seconds after the operator role is created in order to avoid error in cluster create
resource "time_sleep" "role_resources_propagation" {
  create_duration = "20s"

  triggers = {
    operator_role_prefix = local.operator_role_prefix
    operator_role_arns   = jsonencode([for value in aws_iam_role.operator_role : value.arn])
    operator_policy_arns = jsonencode([for value in aws_iam_role_policy_attachment.operator_role_policy_attachment : value.policy_arn])
  }
}

data "aws_partition" "current" {}

data "rhcs_info" "current" {}
