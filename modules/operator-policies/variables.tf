variable "account_role_prefix" {
  type    = string
  default = null
}

variable "openshift_version" {
  description = "The Openshift cluster version of the cluster those account roles are used for. Only major and minor parts (for example 4.1)"
  type        = string
}

variable "shared_vpc_role_arn" {
  description = "The role ARN used to access the private hosted zone, in case shared VPC is used"
  type        = string
  default     = ""
}

variable "tags" {
  description = "List of AWS resource tags to apply."
  type        = map(string)
  default     = null
}
