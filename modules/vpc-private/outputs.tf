output "private_subnets" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "availability_zones" {
  value = local.azs
}
