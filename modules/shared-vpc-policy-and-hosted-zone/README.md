# shared-vpc-policy-and-hosted-zone

## Introduction

This sub-module enables the creation of all essential AWS resources within the shared VPC account to support the shared VPC infrastructure. It encompasses the provisioning of IAM resources to facilitate sharing between accounts, ensuring seamless collaboration and resource access. Additionally, the module handles the configuration of a Route 53 hosted zone, enabling external access into the VPC for enhanced connectivity and service accessibility.

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.shared_vpc_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.shared_vpc_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.shared_vpc_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ram_principal_association.shared_vpc_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.shared_vpc_resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.shared_vpc_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route53_zone.shared_vpc_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [time_sleep.shared_resources_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The cluster's name for which shared resources are created. It's utilized for the Hosted Zone domain. | `string` | n/a | yes |
| <a name="input_hosted_zone_base_domain"></a> [hosted\_zone\_base\_domain](#input\_hosted\_zone\_base\_domain) | The Base Domain that should be used for the Hosted Zone creation. | `string` | n/a | yes |
| <a name="input_ingress_operator_role_arn"></a> [ingress\_operator\_role\_arn](#input\_ingress\_operator\_role\_arn) | Ingress Operator ARN from target account | `string` | n/a | yes |
| <a name="input_installer_role_arn"></a> [installer\_role\_arn](#input\_installer\_role\_arn) | Installer ARN from target account | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix applied to all AWS creations. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The list of the subnets that should be shared between the accounts. | `list(string)` | n/a | yes |
| <a name="input_target_aws_account"></a> [target\_aws\_account](#input\_target\_aws\_account) | The AWS account number in where the cluster is going to be created. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The Shared VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | Hosted Zone ID |
| <a name="output_shared_role"></a> [shared\_role](#output\_shared\_role) | Shared VPC Role ARN |
| <a name="output_shared_subnets"></a> [shared\_subnets](#output\_shared\_subnets) | The Amazon Resource Names (ARN) of the resource share |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
