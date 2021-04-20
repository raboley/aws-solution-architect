module "vpc" {
  source = "../vpc"

}

locals {
  # TODO have this split by number of AZs.
  # Ex. 2 subnets per Availability Zone.
  subnet_cidrs = cidrsubnets(module.vpc.vpc_cidr, 3, 3, 3, 3, 3, 3)
}

module "subnets_a" {
  source = "../vpc/modules/public_private_subnets/"

  vpc_id                  = module.vpc.vpc_id
  vpc_internet_gateway_id = module.vpc.vpc_internet_gateway_id
  availability_zone       = "${var.region}a"
  private_subnet_cidr     = local.subnet_cidrs[0]
  public_subnet_cidr      = local.subnet_cidrs[1]
}

module "subnets_b" {
  source = "../vpc/modules/public_private_subnets/"

  vpc_id                  = module.vpc.vpc_id
  vpc_internet_gateway_id = module.vpc.vpc_internet_gateway_id
  availability_zone       = "${var.region}b"
  private_subnet_cidr     = local.subnet_cidrs[2]
  public_subnet_cidr      = local.subnet_cidrs[3]
}