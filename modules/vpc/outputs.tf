output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "availability_zones" {
  value = local.azs
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
