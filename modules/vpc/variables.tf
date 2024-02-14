variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Cidr block of the desired VPC."
}

variable "name_prefix" {
  type        = string
  description = "User-defined prefix for all generated AWS resources of this VPC"
}

variable "subnet_count" {
  type        = number
  description = "The number of public/private subnet pairs to make."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "AWS tags to be applied to generated AWS resources of this VPC."
}
