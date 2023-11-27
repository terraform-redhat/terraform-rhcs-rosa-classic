variable "ocm_environment" {
  type    = string
  default = "production"
}

variable "openshift_version" {
  type    = string
  default = "4.13.13"
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+.[0-9]*[0-9]+$", var.openshift_version))
    error_message = "openshift_version must be with structure <major>.<minor>.<patch> (for example 4.13.6)."
  }
}

variable "cluster_name" {
  type = string
}

variable "machine_type" {
  description = "Identifier of the machine type used by the nodes, for example `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values."
  type        = string
  default     = "m5.xlarge"
}

variable "autoscaling_enabled" {
  description = "Enables autoscaling. If `true`, this variable requires you to set a maximum and minimum replicas range using the `max_replicas` and `min_replicas` variables."
  type        = bool
  default     = null
}

variable "min_replicas" {
  description = "The minimum number of replicas for autoscaling functionality."
  type        = number
  default     = null
}

variable "max_replicas" {
  description = "The maximum number of replicas for autoscaling functionality."
  type        = number
  default     = null
}

variable "replicas" {
  description = "The amount of the machine created in this machine pool."
  type        = number
  default     = 3
}

variable "create_account_roles" {
  description = "Create the aws account roles for rosa"
  type        = bool
  default     = false
}

variable "account_role_prefix" {
  description = "Account role prefix if not using the default."
  type        = string
  default     = ""
}

variable "create_operator_roles" {
  description = "Create the aws account roles for rosa"
  type        = bool
  default     = false
}

variable "operator_role_prefix" {
  description = "Operator role prefix if not using the default."
  type        = string
  default     = ""
}

variable "create_oidc" {
  description = "Create the oidc resources."
  type        = bool
  default     = false
}

variable "oidc" {
  description = "OIDC create managed unmanaged or do not create."
  type        = string
  default     = "managed"
}

variable "oidc_secret_arn" {
  description = "When creating oidc outside the module you must pass in the secret arn that the oidc-config module created."
  type        = string
  default     = ""
}

variable "oidc_issuer_url" {
  description = "When creating oidc outside the module you must pass in the issuer url that the oidc-config module created."
  type        = string
  default     = ""
}

variable "account_role_path" {
  description = "Output path from ther iam create module"
  type        = string
  default     = ""
}

variable "oidc_endpoint_url" {
  description = "OIDC endpoint URL outputed by the OIDC module."
  type        = string
  default     = ""
}

variable "oidc_config_id" {
  description = "OIDC config id outputed by the OIDC module."
  type        = string
  default     = ""
}

variable "create_vpc" {
  description = "Create the vpc resources."
  type        = bool
  default     = false
}

variable "vpc_public_subnets_ids" {
  description = "Create the vpc resources."
  type        = list
  default     = []
}

variable "vpc_private_subnets_ids" {
  description = "Create the vpc resources."
  type        = list
  default     = []
}

variable "availability_zones" {
  description = "Create the vpc resources."
  type        = list
  default     = []
}

variable "private" {
  description = "Create the vpc resources."
  type        = bool
  default     = false
}

variable "machine_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "machine_pools" {
  type    = map(any)
  default = {}
}

variable "idp" {
  type    = map(any)
  default = {}
}