variable "account_role_prefix" {
  // This variable is mandatory as the account roles are already created
  type        = string
  description = "User-defined prefix for all generated AWS resources (default \"account-role-<random>\")"
}

variable "openshift_version" {
  type        = string
  description = "The Openshift cluster version of the cluster these operator policies are used for."
}

variable "shared_vpc_role_arn" {
  type        = string
  default     = ""
  description = "The role ARN used to access the private hosted zone, in case shared VPC is used"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "List of AWS resource tags to apply."
}
