############################################
# Variables
############################################
variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_collection_name" {
  default = "solution-architect" 
}

############################################
# Resources
############################################

#### VPCs #####################
resource "aws_vpc" "i" {
  cidr_block = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = true
  
  tags = {
    Name = var.vpc_collection_name
  }
}
# Creates a default:
# * Routing table
# * Access Control List
# * Security Group

locals {
  subnet_cidrs = cidrsubnets(var.vpc_cidr_block, 3, 3, 3, 3, 3, 3)
}

#### Subnets #####################
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.i.id
  cidr_block = local.subnet_cidrs[0]
  availability_zone = "${var.region}a"
  
  ## Auto assign public IPs to EC2 instances on launch.
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.i.id
  cidr_block = local.subnet_cidrs[1]
  availability_zone = "${var.region}a"

  tags = {
    Name = "private"
  }
}

#### Internet Gateway ########
resource "aws_internet_gateway" "public" {
  // Only one internet Gateway Per VPC
  vpc_id = aws_vpc.i.id
  
  tags = {
    Name = "my-ig"
  }
}

#### Route Table #############
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.i.id
  
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_out_ipv4" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.public.id
}

resource "aws_route" "public_out_ipv6" {
  route_table_id = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id = aws_internet_gateway.public.id
}

# Only associate with our public subnet. Every subnet associated with this will become public.
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public.id
}

#### ACL #####################
//resource "aws_network_acl" "i" {
//  vpc_id = aws_vpc.i.id
//  subnet_ids = [aws_subnet.private.id]
//
//  tags = {
//    Name = "private"
//  }
//}
