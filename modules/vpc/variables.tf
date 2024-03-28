variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Cidr block of the desired VPC."
}

variable "name_prefix" {
  type        = string
  description = "User-defined prefix for all generated AWS resources of this VPC."
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "A list of availability zones names in the region."
}

variable "availability_zones_count" {
  type        = number
  default     = null
  description = "The count of availability zones to utilize within the specified AWS region, where pairs of public and private subnets are generated. Valid only when availability_zones variable is not provided."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "AWS tags to be applied to generated AWS resources of this VPC."
}
