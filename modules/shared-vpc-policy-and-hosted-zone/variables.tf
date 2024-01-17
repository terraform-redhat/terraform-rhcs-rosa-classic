variable "cluster_name" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = null
}

variable "target_aws_account" {
  description = "Installer ARN from target account"
  type        = string
}

variable "installer_role_arn" {
  description = "Installer ARN from target account"
  type        = string
}

variable "ingress_operator_role_arn" {
  description = "Ingress Operator ARN from target account"
  type        = string
}

variable "subnets" {
  description = "Private subnet"
  type        = list(string)
}

variable "hosted_zone_base_domain" {
  description = "Base Domain"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}
