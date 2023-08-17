variable "name" {
  type = string
}

variable "vpc_cidr" {
  description = "The CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "List of AWS resource tags to apply."
  type        = map(string)
  default     = null
}
