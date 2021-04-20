############################################
# Resources
############################################

#### VPCs #####################
resource "aws_vpc" "i" {
  cidr_block                       = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = var.vpc_name
  }
}
# Creates by default:
# * Routing table
# * Access Control List
# * Security Group

#### Internet Gateway ########
# Only one internet Gateway Per VPC
resource "aws_internet_gateway" "i" {
  vpc_id = aws_vpc.i.id

  tags = {
    Name = "my-ig"
  }
}

