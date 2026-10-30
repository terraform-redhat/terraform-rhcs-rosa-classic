# notification-contacts

## Introduction

This Terraform sub-module manages notification contacts for ROSA Classic clusters. It configures the set of OCM account usernames that receive cluster notification emails for the associated subscription. The contact list is authoritative — the full set of notification contacts is managed by this resource.

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | >= 1.7.10 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_rhcs"></a> [rhcs](#provider\_rhcs) | >= 1.7.10 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [rhcs_cluster_notification_contacts.contacts](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/resources/cluster_notification_contacts) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Identifier of the cluster. | `string` | n/a | yes |
| <a name="input_contacts"></a> [contacts](#input\_contacts) | Set of OCM account usernames to receive cluster notification emails. Values must be OCM usernames, not email addresses — using email addresses can cause persistent plan diffs and may lead to incorrect contact removal. All contacts must belong to the same Red Hat organization as the cluster. This set is authoritative — the full set of contacts is managed by this resource. | `set(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_contacts"></a> [contacts](#output\_contacts) | Set of OCM account usernames configured as notification contacts for the cluster. |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
