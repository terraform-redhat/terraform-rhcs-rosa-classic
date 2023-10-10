output "private_subnets" {
  value = aws_subnet.private_subnet[*].id
}

output "public_subnets" {
  value = aws_subnet.public_subnet[*].id
}

output "availability_zones" {
  value = local.azs
}
