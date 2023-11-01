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

variable "machine_pool_name" {
  description = "Name of the machine pool. Must consist of lower-case alphanumeric characters or '-', start and end with an alphanumeric character."
  type        = string
}

variable "machine_type" {
  description = "Identifier of the machine type used by the nodes, for example `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values."
  type        = string
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
  default     = null
}
