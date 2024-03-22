# trusted_ip_addresses

## Introduction

This Terraform sub-module is dedicated to listing all the known Red Hat trusted ip addresses.
This facilitates users to now have a static machine-parseable list of IPs for adding an additional layer of security in an AWS account to prevent role assumption from non-allowlisted IP addresses and other automation purposes.

For more info see [Red Hat Trusted IP Addresses](https://source.redhat.com/personal_blogs/listing_red_hats_trusted_ip_addresses_using_an_api_enpoint)

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | >= 1.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_rhcs"></a> [rhcs](#provider\_rhcs) | >= 1.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [rhcs_trusted_ip_addresses.all](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/data-sources/trusted_ip_addresses) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_trusted_ip_addresses"></a> [trusted\_ip\_addresses](#output\_trusted\_ip\_addresses) | Trusted Ip Addresses |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
