variable "operator_role_prefix" {
  type        = string
  default     = null
  description = "User-defined prefix for generated AWS operator policies. Use \"account-role-prefix\" in case no value provided."
}

variable "account_role_prefix" {
  type        = string
  description = "User-defined prefix for all generated AWS resources."
}

variable "path" {
  type        = string
  default     = "/"
  description = "The ARN path for the account/operator roles as well as their policies. Must use the same path used for \"account_iam_roles\"."
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

variable "oidc_endpoint_url" {
  type        = string
  description = "Registered OIDC configuration issuer URL, added as the trusted relationship to the operator roles."
}

variable "govcloud" {
  type = bool
  default = false
  description = "Whether or not resources are to be used in a Govcloud environment."
}
