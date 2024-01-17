variable "cluster_name" {
  type = string
}

variable "shared_vpc_aws_key" {
  type = string
}

variable "shared_vpc_aws_secret" {
  type = string
}

variable "shared_vpc_aws_region" {
  type = string
}

variable "shared_vpc_aws_account" {
  type = string
}

variable "shared_vpc_role_name" {
  type    = string
  default = null
}

variable "openshift_version" {
  type    = string
  default = "4.13.13"
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+.[0-9]*[0-9]+$", var.openshift_version))
    error_message = "openshift_version must be with structure <major>.<minor>.<patch> (for example 4.13.6)."
  }
}

variable "account_role_prefix" {
  type    = string
  default = null
}

variable "operator_role_prefix" {
  type    = string
  default = null
}

variable "replicas" {
  description = "The amount of the machine created in this machine pool."
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Identifier of the machine type used by the nodes, for example `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values."
  type        = string
  default     = "m5.xlarge"
}
