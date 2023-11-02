resource "time_sleep" "wait_10_seconds" {
  create_duration = "20s"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  # New configuration to exclude Local Zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  private_cidr_range = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_cidr_range  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_cidr_range
  public_subnets  = local.public_cidr_range

  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" = "${var.name_prefix}-vpc"
    },
    var.tags,
  )
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])

  tags = var.tags
}
