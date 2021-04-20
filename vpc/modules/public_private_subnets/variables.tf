variable "vpc_id" {
  description = "The Id of the VPC these subnets should be placed in."
}

variable "vpc_internet_gateway_id" {
  description = "The id of the internet gateway associated with the vpc"
}

variable "availability_zone" {
  description = "The availability zone for these subnets to be placed in"
}


variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
