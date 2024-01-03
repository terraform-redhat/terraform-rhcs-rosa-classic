// Required
variable "cluster_id" {
  description = "Identifier of the cluster."
  type        = string
}

// Required
variable "name" {
  description = "Name of the machine pool. Must consist of lower-case alphanumeric characters or '-', start and end with an alphanumeric character."
  type        = string
}

// Required
variable "machine_type" {
  description = "Identifier of the machine type used by the nodes, for example `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values."
  type        = string
}

variable "replicas" {
  description = "The amount of the machine created in this machine pool."
  type        = number
  default     = null
}

variable "use_spot_instances" {
  description = "Use Amazon EC2 Spot Instances."
  type        = bool
  default     = null
}

variable "max_spot_price" {
  description = "Max Spot price."
  type        = number
  default     = null
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

variable "taints" {
  description = "Taints for a machine pool. This list will overwrite any modifications made to node taints on an ongoing basis."
  type        = list(object({
    key           = string
    value         = string
    schedule_type = string
  }))
  default = null
}

variable "labels" {
  description = "Labels for the machine pool. Format should be a comma-separated list of 'key = value'. This list will overwrite any modifications made to node labels on an ongoing basis."
  type        = map(string)
  default     = null
}

variable "multi_availability_zone" {
  description = "Create a multi-AZ machine pool for a multi-AZ cluster (default is `true`)"
  type        = bool
  default     = null
}

variable "availability_zone" {
  description = "Select the availability zone in which to create a single AZ machine pool for a multi-AZ cluster"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Select the subnet in which to create a single AZ machine pool for BYO-VPC cluster"
  type        = string
  default     = null
}
