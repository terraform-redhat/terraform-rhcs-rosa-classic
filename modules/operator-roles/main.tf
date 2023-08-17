data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = var.operator_role_prefix
  account_role_prefix  = var.account_role_prefix
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "operator_role" {
  count = length(data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles)

  name                 = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].role_name
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = data.aws_iam_policy_document.custom_trust_policy[count.index].json

  tags = merge(var.tags, {
    red-hat-managed = true
    // TODO nargaman always empty?
    rosa_cluster_id    = var.cluster_id
    operator_namespace = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_namespace
    operator_name      = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].operator_name
  })
}

resource "aws_iam_role_policy_attachment" "operator_role_policy_attachment" {
  count = length(data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles)

  role       = aws_iam_role.operator_role[count.index].name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].policy_name}"
}

data "aws_iam_policy_document" "custom_trust_policy" {
  count = length(data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles)

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_endpoint_url}"]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "${var.oidc_endpoint_url}:sub"
      values   = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles[count.index].service_accounts
    }
  }
}
