module "rosa" {
  source = "../../"

  cluster_name            = var.cluster_name
  openshift_version       = var.openshift_version
  create_account_roles    = true
  create_operator_roles   = true
  create_oidc             = true
  availability_zones      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  vpc_private_subnets_ids = module.vpc.private_subnets
  vpc_public_subnets_ids  = module.vpc.public_subnets
  machine_cidr            = "10.66.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                 = "rhcs-vpc-1"
  cidr                 = "10.66.0.0/16"
  azs                  = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets      = ["10.66.1.0/24", "10.66.2.0/24", "10.66.3.0/24"]
  public_subnets       = ["10.66.101.0/24", "10.66.102.0/24", "10.66.103.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}
