# ROSA Classic with shared VPC example

## Introduction

Terraform manifest example for creating a Red Hat OpenShift Service on AWS (ROSA) cluster. This example provides a structured configuration template that demonstrates how to deploy a ROSA cluster within your AWS environment using Terraform.
This example includes:
- Cluster with public access
- A pre-existing shared VPC within a separate AWS account.

## Prerequisites

* The [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (1.4.6+) installed.
* [AWS account](https://aws.amazon.com/free/?all-free-tier) and [associated credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/security-creds.html) that allow you to create resources. The credentials configured for the AWS provider (see [Authentication and Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) section in AWS terraform provider documentations)
* A secondary AWS account is necessary for the shared VPC resources. Please supply the credentials for this account through the appropriate input variables in the example.
* Completed the [ROSA getting started AWS prerequisites](https://console.redhat.com/openshift/create/rosa/getstarted)
* Valid [OpenShift Cluster Manager API Token](https://console.redhat.com/openshift/token) configured (see [Authentication and configuration](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs#authentication-and-configuration) for more info)

Installation of the following CLI tools is recommended:
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [ROSA CLI](https://docs.openshift.com/rosa/cli_reference/rosa_cli/rosa-get-started-cli.html)
* [Openshift CLI (oc)](https://docs.openshift.com/rosa/cli_reference/openshift_cli/getting-started-cli.html)

For more info about shared VPC see [Configuring a shared VPC for ROSA clusters](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa-shared-vpc-config.html)

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | >= 1.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_aws.shared-vpc"></a> [aws.shared-vpc](#provider\_aws.shared-vpc) | >= 4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |
| <a name="provider_rhcs"></a> [rhcs](#provider\_rhcs) | >= 1.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_iam_resources"></a> [account\_iam\_resources](#module\_account\_iam\_resources) | ../../modules/account-iam-resources | n/a |
| <a name="module_oidc_config_and_provider"></a> [oidc\_config\_and\_provider](#module\_oidc\_config\_and\_provider) | ../../modules/oidc-config-and-provider | n/a |
| <a name="module_operator_policies"></a> [operator\_policies](#module\_operator\_policies) | ../../modules/operator-policies | n/a |
| <a name="module_operator_roles"></a> [operator\_roles](#module\_operator\_roles) | ../../modules/operator-roles | n/a |
| <a name="module_rosa_cluster_classic"></a> [rosa\_cluster\_classic](#module\_rosa\_cluster\_classic) | ../../modules/rosa-cluster-classic | n/a |
| <a name="module_shared-vpc-policy-and-hosted-zone"></a> [shared-vpc-policy-and-hosted-zone](#module\_shared-vpc-policy-and-hosted-zone) | ../../modules/shared-vpc-policy-and-hosted-zone | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.validations](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [rhcs_dns_domain.dns_domain](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/resources/dns_domain) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.shared_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster. After the creation of the resource, it is not possible to update the attribute value. | `string` | n/a | yes |
| <a name="input_openshift_version"></a> [openshift\_version](#input\_openshift\_version) | Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled. | `string` | `"4.14.9"` | no |
| <a name="input_shared_vpc_aws_access_key_id"></a> [shared\_vpc\_aws\_access\_key\_id](#input\_shared\_vpc\_aws\_access\_key\_id) | The access key provides access to AWS services and is associated with the shared-vpc AWS account. | `string` | `""` | no |
| <a name="input_shared_vpc_aws_profile"></a> [shared\_vpc\_aws\_profile](#input\_shared\_vpc\_aws\_profile) | The name of the AWS profile configured in the AWS credentials file (typically located at ~/.aws/credentials). This profile contains the access key, secret key, and optional session token associated with the shared-vpc AWS account. | `string` | `""` | no |
| <a name="input_shared_vpc_aws_secret_access_key"></a> [shared\_vpc\_aws\_secret\_access\_key](#input\_shared\_vpc\_aws\_secret\_access\_key) | The secret key paired with the access key. Together, they provide the necessary credentials for Terraform to authenticate with the shared-vpc AWS account and manage resources securely. | `string` | `""` | no |
| <a name="input_shared_vpc_aws_shared_credentials_files"></a> [shared\_vpc\_aws\_shared\_credentials\_files](#input\_shared\_vpc\_aws\_shared\_credentials\_files) | List of files path to the AWS shared credentials file. This file typically contains AWS access keys and secret keys and is used when authenticating with AWS using profiles (default file located at ~/.aws/credentials). | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
