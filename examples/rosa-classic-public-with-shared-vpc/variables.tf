variable "cluster_name" {
  type = string
}

variable "shared_vpc_aws_access_key_id" {
  type = string
}

variable "shared_vpc_aws_secret_access_key" {
  type = string
}

variable "openshift_version" {
  type    = string
  default = "4.14.9"
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+.[0-9]*[0-9]+$", var.openshift_version))
    error_message = "openshift_version must be with structure <major>.<minor>.<patch> (for example 4.13.6)."
  }
}
