# ROSA Classic Cluster sub-module

## Introduction

This Terraform sub-module helps the provisioning and management of ROSA Classic clusters within AWS infrastructure. Prior to using this sub-module, ensure that AWS IAM roles and policies are already established in the account, along with the necessary OIDC configuration and provider settings.

This sub-module also includes the following resources:
- Autoscaler: allows you to configure and control the scaling behavior of the cluster based on workload demands through the Autoscaler feature.
- Default Ingress: enables the setup and management of the default ingress configuration, allowing seamless routing of external traffic to services deployed within the cluster.

For more information, see [Creating a default ROSA Classic cluster using Terraform](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/terraform/rosa-sts-creating-a-cluster-quickly-terraform.html) in the ROSA documentation.

## Example Usage

```
module "rosa_cluster_classic" {
  source = "terraform-redhat/rosa-classic/rhcs//modules/rosa-cluster-classic"

  cluster_name           = "my-cluster"
  account_role_prefix    = "my-cluster-account"
  operator_role_prefix   = "my-operators"
  openshift_version      = "4.14.24"
  oidc_config_id         = "my-oidc-config-id"
}
```

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_rhcs"></a> [rhcs](#requirement\_rhcs) | = 1.6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_rhcs"></a> [rhcs](#provider\_rhcs) | = 1.6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [rhcs_cluster_autoscaler.cluster_autoscaler](https://registry.terraform.io/providers/terraform-redhat/rhcs/1.6.2/docs/resources/cluster_autoscaler) | resource |
| [rhcs_cluster_rosa_classic.rosa_classic_cluster](https://registry.terraform.io/providers/terraform-redhat/rhcs/1.6.2/docs/resources/cluster_rosa_classic) | resource |
| [rhcs_default_ingress.default_ingress](https://registry.terraform.io/providers/terraform-redhat/rhcs/1.6.2/docs/resources/default_ingress) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.provided_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_role_prefix"></a> [account\_role\_prefix](#input\_account\_role\_prefix) | User-defined prefix for all generated AWS resources (default "account-role-<random>") | `string` | `null` | no |
| <a name="input_additional_trust_bundle"></a> [additional\_trust\_bundle](#input\_additional\_trust\_bundle) | A string containing a PEM-encoded X.509 certificate bundle that is added to the nodes' trusted certificate store. | `string` | `null` | no |
| <a name="input_admin_credentials_password"></a> [admin\_credentials\_password](#input\_admin\_credentials\_password) | Admin password that is created with the cluster. The password must contain at least 14 characters (ASCII-standard) without whitespaces including uppercase letters, lowercase letters, and numbers or symbols. | `string` | `null` | no |
| <a name="input_admin_credentials_username"></a> [admin\_credentials\_username](#input\_admin\_credentials\_username) | Admin username that is created with the cluster. auto generated username - "cluster-admin" | `string` | `null` | no |
| <a name="input_autoscaler_balance_similar_node_groups"></a> [autoscaler\_balance\_similar\_node\_groups](#input\_autoscaler\_balance\_similar\_node\_groups) | Automatically identifies node groups with the same instance type and the same set of labels and tries to keep the respective sizes of those node groups balanced. | `bool` | `null` | no |
| <a name="input_autoscaler_balancing_ignored_labels"></a> [autoscaler\_balancing\_ignored\_labels](#input\_autoscaler\_balancing\_ignored\_labels) | This option specifies labels that cluster autoscaler ignores when considering node group similarity. For example, if you have nodes with 'topology.ebs.csi.aws.com/zone' label, you can add name of this label here to prevent cluster autoscaler from splitting nodes into different node groups based on its value. | `list(string)` | `null` | no |
| <a name="input_autoscaler_cores"></a> [autoscaler\_cores](#input\_autoscaler\_cores) | Minimum and maximum number of cores in cluster, in the format <min>:<max>. Cluster autoscaler does not scale the cluster beyond these numbers. | <pre>object({<br>    min = number<br>    max = number<br>  })</pre> | `null` | no |
| <a name="input_autoscaler_gpus"></a> [autoscaler\_gpus](#input\_autoscaler\_gpus) | Minimum and maximum number of different GPUs in cluster, in the format <gpu\_type>:<min>:<max>. Cluster autoscaler does not scale the cluster beyond these numbers. Can be passed multiple times. | <pre>list(object({<br>    type = string<br>    range = object({<br>      min = number<br>      max = number<br>    })<br>  }))</pre> | `null` | no |
| <a name="input_autoscaler_ignore_daemonsets_utilization"></a> [autoscaler\_ignore\_daemonsets\_utilization](#input\_autoscaler\_ignore\_daemonsets\_utilization) | Should cluster-autoscaler ignore DaemonSet pods when calculating resource utilization for scaling down. Default is false. | `bool` | `null` | no |
| <a name="input_autoscaler_log_verbosity"></a> [autoscaler\_log\_verbosity](#input\_autoscaler\_log\_verbosity) | Sets the autoscaler log level. Default value is 1, level 4 is recommended for DEBUGGING and level 6 enables almost everything. | `number` | `null` | no |
| <a name="input_autoscaler_max_node_provision_time"></a> [autoscaler\_max\_node\_provision\_time](#input\_autoscaler\_max\_node\_provision\_time) | Maximum time cluster-autoscaler waits for node to be provisioned. | `string` | `null` | no |
| <a name="input_autoscaler_max_nodes_total"></a> [autoscaler\_max\_nodes\_total](#input\_autoscaler\_max\_nodes\_total) | Maximum number of nodes in all node groups. Cluster autoscaler does not grow the cluster beyond this number. | `number` | `null` | no |
| <a name="input_autoscaler_max_pod_grace_period"></a> [autoscaler\_max\_pod\_grace\_period](#input\_autoscaler\_max\_pod\_grace\_period) | Gives pods graceful termination time before scaling down. | `number` | `null` | no |
| <a name="input_autoscaler_memory"></a> [autoscaler\_memory](#input\_autoscaler\_memory) | Minimum and maximum number of gigabytes of memory in cluster, in the format <min>:<max>. Cluster autoscaler does not scale the cluster beyond these numbers. | <pre>object({<br>    min = number<br>    max = number<br>  })</pre> | `null` | no |
| <a name="input_autoscaler_pod_priority_threshold"></a> [autoscaler\_pod\_priority\_threshold](#input\_autoscaler\_pod\_priority\_threshold) | To allow users to schedule 'best-effort' pods, which does not trigger cluster autoscaler actions, but only run when there are spare resources available. | `number` | `null` | no |
| <a name="input_autoscaler_scale_down_delay_after_add"></a> [autoscaler\_scale\_down\_delay\_after\_add](#input\_autoscaler\_scale\_down\_delay\_after\_add) | How long after scale up that scale down evaluation resumes. | `string` | `null` | no |
| <a name="input_autoscaler_scale_down_delay_after_delete"></a> [autoscaler\_scale\_down\_delay\_after\_delete](#input\_autoscaler\_scale\_down\_delay\_after\_delete) | How long after node deletion that scale down evaluation resumes. | `string` | `null` | no |
| <a name="input_autoscaler_scale_down_delay_after_failure"></a> [autoscaler\_scale\_down\_delay\_after\_failure](#input\_autoscaler\_scale\_down\_delay\_after\_failure) | How long after scale down failure that scale down evaluation resumes. | `string` | `null` | no |
| <a name="input_autoscaler_scale_down_enabled"></a> [autoscaler\_scale\_down\_enabled](#input\_autoscaler\_scale\_down\_enabled) | Should cluster-autoscaler scale down the cluster. | `bool` | `null` | no |
| <a name="input_autoscaler_scale_down_unneeded_time"></a> [autoscaler\_scale\_down\_unneeded\_time](#input\_autoscaler\_scale\_down\_unneeded\_time) | How long a node should be unneeded before it is eligible for scale down. | `string` | `null` | no |
| <a name="input_autoscaler_scale_down_utilization_threshold"></a> [autoscaler\_scale\_down\_utilization\_threshold](#input\_autoscaler\_scale\_down\_utilization\_threshold) | Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. | `string` | `null` | no |
| <a name="input_autoscaler_skip_nodes_with_local_storage"></a> [autoscaler\_skip\_nodes\_with\_local\_storage](#input\_autoscaler\_skip\_nodes\_with\_local\_storage) | If true, cluster autoscaler never deletes nodes with pods with local storage, e.g. EmptyDir or HostPath. Default is true. | `bool` | `null` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Enable autoscaling for the initial worker pool. (default: false) | `bool` | `null` | no |
| <a name="input_aws_account_arn"></a> [aws\_account\_arn](#input\_aws\_account\_arn) | The ARN of the AWS account where all resources are created during the installation of the ROSA cluster. If no information is provided, the data is retrieved from the currently connected account. | `string` | `null` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS account identifier where all resources are created during the installation of the ROSA cluster. If no information is provided, the data is retrieved from the currently connected account. | `string` | `null` | no |
| <a name="input_aws_additional_compute_security_group_ids"></a> [aws\_additional\_compute\_security\_group\_ids](#input\_aws\_additional\_compute\_security\_group\_ids) | The additional security group IDs to be added to the default worker machine pool. | `list(string)` | `null` | no |
| <a name="input_aws_additional_control_plane_security_group_ids"></a> [aws\_additional\_control\_plane\_security\_group\_ids](#input\_aws\_additional\_control\_plane\_security\_group\_ids) | The additional security group IDs to be added to the control plane nodes. | `list(string)` | `null` | no |
| <a name="input_aws_additional_infra_security_group_ids"></a> [aws\_additional\_infra\_security\_group\_ids](#input\_aws\_additional\_infra\_security\_group\_ids) | The additional security group IDs to be added to the infra worker nodes. | `list(string)` | `null` | no |
| <a name="input_aws_availability_zones"></a> [aws\_availability\_zones](#input\_aws\_availability\_zones) | The AWS availability zones where instances of the default worker machine pool are deployed. Leave blank for the installer to pick availability zones. | `list(string)` | `[]` | no |
| <a name="input_aws_private_link"></a> [aws\_private\_link](#input\_aws\_private\_link) | Provides private connectivity between VPCs, AWS services, and on-premises networks, without exposing traffic to the public internet. (default: false) | `bool` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The full name of the AWS region used for the ROSA cluster installation, for example 'us-east-1'. If no information is provided, the data is retrieved from the currently connected account. | `string` | `null` | no |
| <a name="input_aws_subnet_ids"></a> [aws\_subnet\_ids](#input\_aws\_subnet\_ids) | The Subnet IDs to use when installing the cluster. Leave blank for installer provisioned subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_base_dns_domain"></a> [base\_dns\_domain](#input\_base\_dns\_domain) | Base DNS domain name previously reserved and matching the hosted zone name of the private Route 53 hosted zone associated with intended shared VPC, e.g., '1vo8.p1.openshiftapps.com'. | `string` | `null` | no |
| <a name="input_cluster_autoscaler_enabled"></a> [cluster\_autoscaler\_enabled](#input\_cluster\_autoscaler\_enabled) | Enable autoscaler for this cluster. | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster. After resource creation, the attribute value cannot be updated. | `string` | n/a | yes |
| <a name="input_compute_machine_type"></a> [compute\_machine\_type](#input\_compute\_machine\_type) | Identifies the instance type used by the default worker machine pool e.g. `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values. | `string` | `null` | no |
| <a name="input_controlplane_role_arn"></a> [controlplane\_role\_arn](#input\_controlplane\_role\_arn) | The Amazon Resource Name (ARN) associated with the AWS IAM role that is used by the cluster's control plane instances. | `string` | `null` | no |
| <a name="input_create_admin_user"></a> [create\_admin\_user](#input\_create\_admin\_user) | To create cluster admin user with default username `cluster-admin` and generated password. It will be ignored if `admin_credentials_username` or `admin_credentials_password` is set. (default: false) | `bool` | `null` | no |
| <a name="input_default_ingress_cluster_routes_hostname"></a> [default\_ingress\_cluster\_routes\_hostname](#input\_default\_ingress\_cluster\_routes\_hostname) | Components route hostname for oauth, console, download. | `string` | `null` | no |
| <a name="input_default_ingress_cluster_routes_tls_secret_ref"></a> [default\_ingress\_cluster\_routes\_tls\_secret\_ref](#input\_default\_ingress\_cluster\_routes\_tls\_secret\_ref) | Components route TLS secret reference for oauth, console, download. | `string` | `null` | no |
| <a name="input_default_ingress_excluded_namespaces"></a> [default\_ingress\_excluded\_namespaces](#input\_default\_ingress\_excluded\_namespaces) | Excluded namespaces for ingress. Format should be a comma-separated list 'value1, value2...'. If no values are specified, all namespaces are exposed. | `list(string)` | `null` | no |
| <a name="input_default_ingress_id"></a> [default\_ingress\_id](#input\_default\_ingress\_id) | Unique identifier of the ingress. | `string` | `null` | no |
| <a name="input_default_ingress_load_balancer_type"></a> [default\_ingress\_load\_balancer\_type](#input\_default\_ingress\_load\_balancer\_type) | Type of Load Balancer. Options are ["classic", "nlb"]`:with.` | `string` | `null` | no |
| <a name="input_default_ingress_route_namespace_ownership_policy"></a> [default\_ingress\_route\_namespace\_ownership\_policy](#input\_default\_ingress\_route\_namespace\_ownership\_policy) | Namespace Ownership Policy for ingress. Options are ["Strict", "InterNamespaceAllowed"]. Default is "Strict". | `string` | `null` | no |
| <a name="input_default_ingress_route_selectors"></a> [default\_ingress\_route\_selectors](#input\_default\_ingress\_route\_selectors) | Route Selectors for ingress. Format should be a comma-separated list of 'key=value'. If no label is specified, all routes are exposed on both routers. For legacy ingress support these are inclusion labels, otherwise they are treated as exclusion label. | `map(string)` | `null` | no |
| <a name="input_default_ingress_route_wildcard_policy"></a> [default\_ingress\_route\_wildcard\_policy](#input\_default\_ingress\_route\_wildcard\_policy) | Wildcard Policy for ingress. Options are ["WildcardsDisallowed", "WildcardsAllowed"]. Default is "WildcardsDisallowed". | `string` | `null` | no |
| <a name="input_default_mp_labels"></a> [default\_mp\_labels](#input\_default\_mp\_labels) | Labels for the worker machine pool. This list overwrites any modifications made to node labels on an ongoing basis. | `map(string)` | `null` | no |
| <a name="input_destroy_timeout"></a> [destroy\_timeout](#input\_destroy\_timeout) | Maximum duration in minutes to allow for destroying resources. (Default: 60 minutes) | `number` | `null` | no |
| <a name="input_disable_scp_checks"></a> [disable\_scp\_checks](#input\_disable\_scp\_checks) | Indicates if cloud permission checks are disabled when attempting installation of the cluster. | `bool` | `null` | no |
| <a name="input_disable_waiting_in_destroy"></a> [disable\_waiting\_in\_destroy](#input\_disable\_waiting\_in\_destroy) | Disable addressing cluster state in the destroy resource. Default value is false, and so a `destroy` waits for the cluster to be deleted. | `bool` | `null` | no |
| <a name="input_disable_workload_monitoring"></a> [disable\_workload\_monitoring](#input\_disable\_workload\_monitoring) | Enables you to monitor your own projects in isolation from Red Hat Site Reliability Engineer (SRE) platform metrics. | `bool` | `null` | no |
| <a name="input_ec2_metadata_http_tokens"></a> [ec2\_metadata\_http\_tokens](#input\_ec2\_metadata\_http\_tokens) | Should cluster nodes use both v1 and v2 endpoints or just v2 endpoint of EC2 Instance Metadata Service (IMDS). Available since OpenShift 4.11.0. | `string` | `null` | no |
| <a name="input_etcd_encryption"></a> [etcd\_encryption](#input\_etcd\_encryption) | Add etcd encryption. By default etcd data is encrypted at rest. This option configures etcd encryption on top of existing storage encryption. | `bool` | `null` | no |
| <a name="input_fips"></a> [fips](#input\_fips) | Create cluster that uses FIPS Validated / Modules in Process cryptographic libraries. | `bool` | `null` | no |
| <a name="input_host_prefix"></a> [host\_prefix](#input\_host\_prefix) | Subnet prefix length to assign to each individual node. For example, if host prefix is set to "23", then each node is assigned a /23 subnet out of the given CIDR. | `number` | `null` | no |
| <a name="input_http_proxy"></a> [http\_proxy](#input\_http\_proxy) | A proxy URL to use for creating HTTP connections outside the cluster. The URL scheme must be http. | `string` | `null` | no |
| <a name="input_https_proxy"></a> [https\_proxy](#input\_https\_proxy) | A proxy URL to use for creating HTTPS connections outside the cluster. | `string` | `null` | no |
| <a name="input_installer_role_arn"></a> [installer\_role\_arn](#input\_installer\_role\_arn) | The Amazon Resource Name (ARN) associated with the AWS IAM role used by the ROSA installer. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The key ARN is the Amazon Resource Name (ARN) of a CMK. It is a unique, fully qualified identifier for the CMK. A key ARN includes the AWS account, region, and the key ID. | `string` | `null` | no |
| <a name="input_machine_cidr"></a> [machine\_cidr](#input\_machine\_cidr) | Block of IP addresses used by OpenShift while installing the cluster, for example "10.0.0.0/16". | `string` | `null` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | Maximum number of compute nodes. This attribute is applicable solely when autoscaling is enabled. (default: 2) | `number` | `null` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | Minimum number of compute nodes. This attribute is applicable solely when autoscaling is enabled. (default: 2) | `number` | `null` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Specifies whether the deployment of the cluster should extend across multiple availability zones. (default: false) | `bool` | `null` | no |
| <a name="input_no_proxy"></a> [no\_proxy](#input\_no\_proxy) | A comma-separated list of destination domain names, domains, IP addresses or other network CIDRs to exclude proxying. | `string` | `null` | no |
| <a name="input_oidc_config_id"></a> [oidc\_config\_id](#input\_oidc\_config\_id) | The unique identifier associated with users authenticated through OpenID Connect (OIDC) within the ROSA cluster. | `string` | n/a | yes |
| <a name="input_openshift_version"></a> [openshift\_version](#input\_openshift\_version) | Desired version of OpenShift for the cluster, for example '4.1.0'. If the version is later than the currently running version, an upgrade is scheduled. | `string` | n/a | yes |
| <a name="input_operator_role_prefix"></a> [operator\_role\_prefix](#input\_operator\_role\_prefix) | A designated prefix used for the creation of AWS IAM roles associated with operators within the ROSA environment. | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | The ARN path for the account/operator roles as well as their policies. | `string` | `"/"` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | Block of IP addresses from which pod IP addresses are allocated, for example "10.128.0.0/14". | `string` | `null` | no |
| <a name="input_private"></a> [private](#input\_private) | Restrict master API endpoint and application routes to direct, private connectivity. (default: false) | `bool` | `null` | no |
| <a name="input_private_hosted_zone_id"></a> [private\_hosted\_zone\_id](#input\_private\_hosted\_zone\_id) | ID assigned by AWS to private Route 53 hosted zone associated with intended shared VPC, e.g., 'Z05646003S02O1ENCDCSN'. | `string` | `null` | no |
| <a name="input_private_hosted_zone_role_arn"></a> [private\_hosted\_zone\_role\_arn](#input\_private\_hosted\_zone\_role\_arn) | AWS IAM role ARN with a policy attached, granting permissions necessary to create and manage Route 53 DNS records in private Route 53 hosted zone associated with intended shared VPC. | `string` | `null` | no |
| <a name="input_properties"></a> [properties](#input\_properties) | User defined properties. | `map(string)` | `null` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of worker nodes to provision. This attribute is applicable solely when autoscaling is disabled. Single zone clusters need at least 2 nodes, multizone clusters need at least 3 nodes. Hosted clusters require that the number of worker nodes be a multiple of the number of private subnets. (default: 2) | `number` | `null` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Block of IP addresses for services, for example "172.30.0.0/16". | `string` | `null` | no |
| <a name="input_support_role_arn"></a> [support\_role\_arn](#input\_support\_role\_arn) | The Amazon Resource Name (ARN) associated with the AWS IAM role used by Red Hat SREs to enable access to the cluster account in order to provide support. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Apply user defined tags to all cluster resources created in AWS. After the creation of the cluster is completed, it is not possible to update this attribute. | `map(string)` | `null` | no |
| <a name="input_upgrade_acknowledgements_for"></a> [upgrade\_acknowledgements\_for](#input\_upgrade\_acknowledgements\_for) | Indicates acknowledgement of agreements required to upgrade the cluster version between minor versions (e.g. a value of "4.12" indicates acknowledgement of any agreements required to upgrade to OpenShift 4.12.z from 4.11 or before). | `bool` | `null` | no |
| <a name="input_wait_for_create_complete"></a> [wait\_for\_create\_complete](#input\_wait\_for\_create\_complete) | Wait until the cluster is either in a ready state or in an error state. The waiter has a timeout of 60 minutes. (default: true) | `bool` | `true` | no |
| <a name="input_worker_disk_size"></a> [worker\_disk\_size](#input\_worker\_disk\_size) | Default worker machine pool root disk size with a **unit suffix** like GiB or TiB, e.g. 200GiB. | `number` | `null` | no |
| <a name="input_worker_role_arn"></a> [worker\_role\_arn](#input\_worker\_role\_arn) | The Amazon Resource Name (ARN) associated with the AWS IAM role that is used by the cluster's compute instances. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_url"></a> [api\_url](#output\_api\_url) | URL of the API server. |
| <a name="output_cluster_admin_password"></a> [cluster\_admin\_password](#output\_cluster\_admin\_password) | The password of the admin user. |
| <a name="output_cluster_admin_username"></a> [cluster\_admin\_username](#output\_cluster\_admin\_username) | The username of the admin user. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Unique identifier of the cluster. |
| <a name="output_console_url"></a> [console\_url](#output\_console\_url) | URL of the console. |
| <a name="output_current_version"></a> [current\_version](#output\_current\_version) | The currently running version of OpenShift on the cluster, for example '4.11.0'. |
| <a name="output_domain"></a> [domain](#output\_domain) | DNS domain of cluster. |
| <a name="output_infra_id"></a> [infra\_id](#output\_infra\_id) | The ROSA cluster infrastructure ID. |
| <a name="output_private_hosted_zone_id"></a> [private\_hosted\_zone\_id](#output\_private\_hosted\_zone\_id) | ID assigned by AWS to private Route 53 hosted zone associated with intended shared VPC |
| <a name="output_state"></a> [state](#output\_state) | The state of the cluster. |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
