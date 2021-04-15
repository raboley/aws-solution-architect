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


