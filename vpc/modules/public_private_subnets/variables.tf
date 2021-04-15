variable "vpc_id" {
  description = "The Id of the VPC these subnets should be placed in."
}

variable "availability_zone" {
  description = "The availability zone for these subnets to be placed in"
}

variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
