variable "cluster_name" {
  type        = string
  description = "The cluster's name for which shared resources are created. It is used for the hosted zone domain."
}

variable "name_prefix" {
  type        = string
  description = "The prefix applied to all AWS creations."
}

variable "target_aws_account" {
  type        = string
  description = "The AWS account number where the cluster is created."
}

variable "installer_role_arn" {
  type        = string
  description = "Installer ARN from target account."
}

variable "ingress_operator_role_arn" {
  type        = string
  description = "Ingress Operator ARN from target account."
}

variable "subnets" {
  type        = list(string)
  description = "The list of the subnets that must be shared between the accounts."
}

variable "hosted_zone_base_domain" {
  type        = string
  description = "The base domain that must be used for hosted zone creation."
}

variable "vpc_id" {
  type        = string
  description = "The Shared VPC ID."
}
