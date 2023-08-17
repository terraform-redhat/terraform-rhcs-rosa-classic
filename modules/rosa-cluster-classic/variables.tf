variable "operator_role_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "openshift_version" {
  description = "Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled."
  type        = string
}

variable "replicas" {
  description = "The amount of the machine created in this machine pool."
  type        = number
  default     = null
}

variable "installer_role_arn" {
  type = string
}

variable "support_role_arn" {
  type        = string
  description = "STS Role ARN with get secrets permission"
}

variable "controlplane_role_arn" {
  type        = string
  description = "STS Role ARN with get secrets permission"
}

variable "worker_role_arn" {
  type        = string
  description = "STS Role ARN with get secrets permission"
}

variable "oidc_config_id" {
  type = string
}

variable "subnets" {
  type    = list(string)
  default = null
}

variable "availability_zones" {
  type    = list(string)
  default = null
}

variable "aws_private_link" {
  type    = bool
  default = false
}

variable "private" {
  type    = bool
  default = false
}

variable "multi_az" {
  type    = bool
  default = false
}
