data "aws_availability_zones" "available" {
  state = "available"

  # Exclude Local Zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_region" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_vpc" "site" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.site.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]
  domain_name         = "ec2.internal"
}

resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id            = aws_vpc.site.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = local.azs[count.index % length(local.azs)]
  tags = {
    Name = join("-", [var.name, "subnet", "public${count.index + 1}", local.azs[count.index % length(local.azs)]])
  }
}

resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.site.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = local.azs[count.index % length(local.azs)]
  tags = {
    Name = join("-", [var.name, "subnet", "private${count.index + 1}", local.azs[count.index % length(local.azs)]])
  }
}


#
# Internet gateway
#
resource "aws_internet_gateway" "site" {
  vpc_id = aws_vpc.site.id
  tags = {
    Name = join("-", [var.name, "igw"])
  }
}

#
# Elastic IPs for NAT gateways
#
resource "aws_eip" "nat" {
  count = length(local.azs)

  vpc = true
  tags = {
    Name = join("-", [var.name, "eip", local.azs[count.index % length(local.azs)]])
  }
}


#
# NAT gateways
#
resource "aws_nat_gateway" "public" {
  count = length(local.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = join("-", [var.name, "nat", "public${count.index}", local.azs[count.index % length(local.azs)]])
  }
}

#
# Route tables
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.site.id
  tags = {
    Name = join("-", [var.name, "rtb", "public"])
  }
}

resource "aws_route_table" "private" {
  count = length(local.azs)

  vpc_id = aws_vpc.site.id
  tags = {
    Name = join("-", [var.name, "rtb", "private${count.index}", local.azs[count.index % length(local.azs)]])
  }
}

#
# Routes
#
# Send all IPv4 traffic to the internet gateway
resource "aws_route" "ipv4_egress_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.site.id
  depends_on             = [aws_route_table.public]
}

# Send all IPv6 traffic to the internet gateway
resource "aws_route" "ipv6_egress_route" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.site.id
  depends_on                  = [aws_route_table.public]
}

# Send private traffic to NAT
resource "aws_route" "private_nat" {
  count = length(local.azs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[count.index].id
  depends_on             = [aws_route_table.private, aws_nat_gateway.public]
}


# Private route for vpc endpoint
resource "aws_vpc_endpoint_route_table_association" "private" {
  count = length(local.azs)

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

#
# Route table associations
#
resource "aws_route_table_association" "public" {
  count = length(local.azs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(local.azs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
