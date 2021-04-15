variable "availability_zone" {
  description = "The AWS availability zone to deploy your subnets into."
  default     = "us-west-2a"
}

variable "vpc_cidr_block" {
  description = "The cidr block range that your VPC should span."
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name of the vpc that will be created."
  default     = "solution-architect"
}