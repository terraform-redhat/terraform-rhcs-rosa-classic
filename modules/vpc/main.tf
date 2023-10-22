locals {
  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  private_cidr_range = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_cidr_range  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]
}

resource "aws_vpc" "new_vpc" {
  cidr_block           = var.vpc_cidr
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
  vpc_id       = aws_vpc.new_vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = concat(
    aws_route_table.private_routes.*.id,
    aws_route_table.default.*.id,
  )

  tags = var.tags
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = data.aws_region.current.name == "us-east-1" ? "ec2.internal" : format("%s.compute.internal", data.aws_region.current.name)
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = var.tags
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.new_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-igw"
    },
    var.tags,
  )
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-public"
    },
    var.tags,
  )
}

resource "aws_main_route_table_association" "main_vpc_routes" {
  vpc_id         = aws_vpc.new_vpc.id
  route_table_id = aws_route_table.default.id
}

resource "aws_route" "igw_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.default.id
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "20m"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(local.azs)

  vpc_id            = aws_vpc.new_vpc.id
  cidr_block        = local.public_cidr_range[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    {
      "Name" = "${var.name_prefix}-public-${local.azs[count.index]}"
    },
    var.tags,
  )
}

resource "aws_route_table_association" "route_net" {
  count = length(local.azs)

  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_eip" "nat_eip" {
  count = length(local.azs)
  vpc   = true

  tags = merge(
    {
      "Name" = "${var.name_prefix}-eip-${local.azs[count.index]}"
    },
    var.tags,
  )

  # Terraform does not declare an explicit dependency towards the internet gateway.
  # this can cause the internet gateway to be deleted/detached before the EIPs.
  # https://github.com/coreos/tectonic-installer/issues/1017#issuecomment-307780549
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(local.azs)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-nat-${local.azs[count.index]}"
    },
    var.tags,
  )

  # https://issues.redhat.com/browse/OCPBUGS-891
  depends_on = [aws_eip.nat_eip, aws_subnet.public_subnet]
}

resource "aws_route_table" "private_routes" {
  count = length(local.azs)

  vpc_id = aws_vpc.new_vpc.id

  tags = merge(
    {
      "Name" = "${var.name_prefix}-private-${local.azs[count.index]}"
    },
    var.tags,
  )
}

resource "aws_route" "to_nat_gw" {
  count = length(local.azs)

  route_table_id         = aws_route_table.private_routes[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
  depends_on             = [aws_route_table.private_routes]

  timeouts {
    create = "20m"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(local.azs)

  vpc_id = aws_vpc.new_vpc.id

  cidr_block = local.private_cidr_range[count.index]

  availability_zone = local.azs[count.index]

  tags = merge(
    {
      "Name"                            = "${var.name_prefix}-private-${local.azs[count.index]}"
      "kubernetes.io/role/internal-elb" = ""
    },
    var.tags,
  )
}

resource "aws_route_table_association" "private_routing" {
  count = length(local.azs)

  route_table_id = aws_route_table.private_routes[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
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
