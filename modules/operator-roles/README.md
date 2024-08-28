# operator-roles

## Introduction

This Terraform sub-module manages the IAM roles used by operators within the cluster for their necessary actions in the AWS account.

The following permissions are included in this sub-module:
- ROSA Ingress Operator IAM role.
- ROSA back-end storage IAM role.
- ROSA Machine Config Operator role.
- ROSA Cloud Credential Operator role.
- ROSA Image Registry Operator role.

For more information, see the [operator-policies sub-module description](../operator-policies/README.md) and [About IAM resources for ROSA clusters that use STS](https://docs.openshift.com/rosa/rosa_architecture/rosa-sts-about-iam-resources.html#rosa-sts-about-iam-resources) in the ROSA documentation.

## Example Usage

```
module "operator_policies" {
  source = "terraform-redhat/rosa-classic/rhcs//modules/operator-policies"

  account_role_prefix  = "my-cluster-account"
  openshift_version    = "4.14.24"
}

module "operator_roles" {
  source = "terraform-redhat/rosa-classic/rhcs//modules/operator-roles"

  operator_role_prefix = "my-cluster-operator"
  account_role_prefix  = "my-cluster-account"
  oidc_endpoint_url    = "my-url"
}
```

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | >= 1.6.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_rhcs"></a> [rhcs](#provider\_rhcs) | >= 1.6.2 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.operator_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.operator_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [time_sleep.role_resources_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.custom_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [rhcs_rosa_operator_roles.operator_roles](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/data-sources/rosa_operator_roles) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_role_prefix"></a> [account\_role\_prefix](#input\_account\_role\_prefix) | User-defined prefix for all generated AWS resources. | `string` | n/a | yes |
| <a name="input_oidc_endpoint_url"></a> [oidc\_endpoint\_url](#input\_oidc\_endpoint\_url) | Registered OIDC configuration issuer URL, added as the trusted relationship to the operator roles. | `string` | n/a | yes |
| <a name="input_operator_role_prefix"></a> [operator\_role\_prefix](#input\_operator\_role\_prefix) | User-defined prefix for generated AWS operator policies. Use "account-role-prefix" in case no value provided. | `string` | `null` | no |
| <a name="input_path"></a> [path](#input\_path) | The ARN path for the account/operator roles as well as their policies. Must use the same path used for "account\_iam\_roles". | `string` | `"/"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the IAM roles in STS clusters. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of AWS resource tags to apply. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_operator_role_prefix"></a> [operator\_role\_prefix](#output\_operator\_role\_prefix) | Prefix used for generated AWS operator policies. |
| <a name="output_operator_roles_arn"></a> [operator\_roles\_arn](#output\_operator\_roles\_arn) | List of Amazon Resource Names (ARNs) for all operator roles created. |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
