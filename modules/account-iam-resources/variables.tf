variable "account_role_prefix" {
  type        = string
  default     = null
  description = "User-defined prefix for all generated AWS resources (default \"account-role-<random>\")"
}

variable "openshift_version" {
  type        = string
  description = "The Openshift cluster version of the cluster those account roles are used for."
}

variable "path" {
  type        = string
  default     = "/"
  description = "The ARN path for the account/operator roles as well as their policies."
}

variable "permissions_boundary" {
  type        = string
  default     = ""
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM roles in STS clusters."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "List of AWS resource tags to apply."
}
