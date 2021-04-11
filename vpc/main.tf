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
  cidr_block                       = var.vpc_cidr_block
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
  vpc_id            = aws_vpc.i.id
  cidr_block        = local.subnet_cidrs[0]
  availability_zone = "${var.region}a"

  ## Auto assign public IPs to EC2 instances on launch.
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.i.id
  cidr_block        = local.subnet_cidrs[1]
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
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route" "public_out_ipv6" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.public.id
}

# Only associate with our public subnet. Every subnet associated with this will become public.
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

#### Security Groups ########
resource "aws_security_group" "public" {
  vpc_id = aws_vpc.i.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  name   = "private"
  vpc_id = aws_vpc.i.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = -1
    protocol        = "icmp"
    to_port         = -1
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    from_port       = 22
    protocol        = "tcp"
    to_port         = 22
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    from_port       = 8080
    protocol        = "tcp"
    to_port         = 8080
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [aws_security_group.public.id]
  }

  ingress {
    from_port       = 3306
    protocol        = "tcp"
    to_port         = 3306
    security_groups = [aws_security_group.public.id]
  }
}

#### Nat Gateways ############
# This will allow our private subnet to access the internet to download stuff.
resource "aws_eip" "nat_gateway" {}

resource "aws_nat_gateway" "i" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id
}

# Once nat gateway is created, need to update our main route table to add a route to the nat gateway.
resource "aws_route" "nat_gateway" {
  route_table_id = aws_vpc.i.main_route_table_id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.i.id
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
