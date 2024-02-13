output "private_subnets" {
  value       = aws_subnet.private_subnet[*].id
  description = "List of private subnets created this this AWS VPC"
}

output "public_subnets" {
  value       = aws_subnet.public_subnet[*].id
  description = "List of public subnets created this this AWS VPC"
}

output "availability_zones" {
  value       = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  description = "List of the Availability Zone names used for the VPC creation"
}

output "vpc_id" {
  value       = time_sleep.vpc_resources_wait.triggers["vpc_id"]
  description = "The unique ID of the VPC"
}
