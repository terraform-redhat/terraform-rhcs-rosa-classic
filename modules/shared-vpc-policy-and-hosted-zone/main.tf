locals {
  resource_arn_prefix = "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/"
}

resource "aws_iam_role" "shared_vpc_role" {
  name = "${var.name_prefix}-shared-vpc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = [
            var.ingress_operator_role_arn,
            var.installer_role_arn
          ]
        }
      }
    ]
  })
  description = "Role that will be assumed from the Target AWS account where the cluster resides"
  lifecycle {
    ignore_changes = [managed_policy_arns]
  }
}

resource "aws_iam_policy" "shared_vpc_policy" {
  name = "${var.name_prefix}-shared-vpc-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ListResourceRecordSets",
          "route53:ChangeTagsForResource",
          "route53:GetAccountLimit",
          "route53:GetChange",
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "route53:UpdateHostedZoneComment",
          "tag:GetResources",
          "tag:UntagResources"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "shared_vpc_role_policy_attachment" {
  role       = aws_iam_role.shared_vpc_role.name
  policy_arn = aws_iam_policy.shared_vpc_policy.arn
}

resource "aws_ram_resource_share" "shared_vpc_resource_share" {
  name                      = "${var.name_prefix}-shared-vpc-resource-share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "shared_vpc_resource_share" {
  principal          = var.target_aws_account
  resource_share_arn = aws_ram_resource_share.shared_vpc_resource_share.arn
}

resource "aws_ram_resource_association" "shared_vpc_resource_association" {
  count = length(var.subnets)

  resource_arn       = "${local.resource_arn_prefix}${var.subnets[count.index]}"
  resource_share_arn = aws_ram_resource_share.shared_vpc_resource_share.arn
}

resource "aws_route53_zone" "shared_vpc_hosted_zone" {
  name = "${var.cluster_name}.${var.hosted_zone_base_domain}"

  vpc {
    vpc_id = var.vpc_id
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

# This resource is utilized to establish dependencies on all resources.
# Some resources, such as aws_ram_principle_associasion, may not have their output utilized, but they are crucial for the cluster.
# Hence, the creation of these resources must be finalized prior to the initiation of cluster creation, and they should not be removed before the cluster is destroyed.
resource "time_sleep" "shared_resources_propagation" {
  destroy_duration = "20s"
  create_duration  = "20s"

  triggers = {
    shared_vpc_hosted_zone_id = aws_route53_zone.shared_vpc_hosted_zone.id
    shared_vpc_role_arn       = aws_iam_role.shared_vpc_role.arn
    resource_share_arn        = aws_ram_principal_association.shared_vpc_resource_share.resource_share_arn
    policy_arn                = aws_iam_role_policy_attachment.shared_vpc_role_policy_attachment.policy_arn
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
