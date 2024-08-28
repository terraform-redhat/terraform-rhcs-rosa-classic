# operator-policies

## Introduction

This Terraform sub-module manages the IAM policies linked to the roles used by operators within the cluster for their necessary actions in the AWS account.

The following permissions are included in this sub-module:
- ROSA Ingress Operator IAM policy: This IAM policy grants the ROSA Ingress Operator the necessary permissions to oversee external access to a cluster.
- ROSA back-end storage IAM policy: This IAM policy is essential for ROSA to manage back-end storage through the Container Storage Interface (CSI).
- ROSA Machine Config Operator policy: This IAM policy furnishes the ROSA Machine Config Operator with the permissions required to execute core cluster functionalities.
- ROSA Cloud Credential Operator policy: This IAM policy offers the ROSA Cloud Credential Operator the necessary permissions for managing cloud provider credentials.
- ROSA Image Registry Operator policy: This IAM policy provides the ROSA Image Registry Operator with permissions to manage the OpenShift image registry storage in AWS S3 for a cluster.

For more information, see the [operator-roles sub-module description](../operator-roles/README.md) and [About IAM resources for ROSA clusters that use STS](https://docs.openshift.com/rosa/rosa_architecture/rosa-sts-about-iam-resources.html#rosa-sts-about-iam-resources) in the ROSA documentation.

## Example Usage

```
module "operator_policies" {
  source = "terraform-redhat/rosa-classic/rhcs//modules/operator-policies"

  account_role_prefix  = "my-cluster-account"
  openshift_version    = "4.14.24"
}
```

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | >= 1.6.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |
| <a name="provider_rhcs"></a> [rhcs](#provider\_rhcs) | >= 1.6.2 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.operator-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [null_resource.validate_openshift_version](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.operator_policy_wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [rhcs_policies.all_policies](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/data-sources/policies) | data source |
| [rhcs_versions.all_versions](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/data-sources/versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_role_prefix"></a> [account\_role\_prefix](#input\_account\_role\_prefix) | User-defined prefix for all generated AWS resources (default "account-role-<random>") | `string` | n/a | yes |
| <a name="input_openshift_version"></a> [openshift\_version](#input\_openshift\_version) | The Openshift cluster version of the cluster these operator policies are used for. | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | The ARN path for the account/operator roles as well as their policies. Must use the same path used for "account\_iam\_roles". | `string` | `"/"` | no |
| <a name="input_shared_vpc_role_arn"></a> [shared\_vpc\_role\_arn](#input\_shared\_vpc\_role\_arn) | The role ARN used to access the private hosted zone, in case shared VPC is used. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of AWS resource tags to apply. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_role_prefix"></a> [account\_role\_prefix](#output\_account\_role\_prefix) | User-defined prefix for all generated AWS resources (default "account-role-<random>") |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
