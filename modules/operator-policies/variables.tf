variable "account_role_prefix" {
  type    = string
  default = null
}

variable "openshift_version" {
  description = "The Openshift cluster version of the cluster those account roles are used for. Only major and minor parts (for example 4.1)"
  type        = string
}

variable "tags" {
  description = "List of AWS resource tags to apply."
  type        = map(string)
  default     = null
}
