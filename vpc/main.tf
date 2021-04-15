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

locals {
  # TODO have this split by number of AZs.
  # Ex. 2 subnets per Availability Zone.
  subnet_cidrs = cidrsubnets(var.vpc_cidr_block, 3, 3, 3, 3, 3, 3)
}

#### Subnets #####################
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.i.id
  cidr_block        = local.subnet_cidrs[0]
  availability_zone = var.availability_zone

  # Auto assign public IPs to EC2 instances on launch in the public subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.i.id
  cidr_block        = local.subnet_cidrs[1]
  availability_zone = var.availability_zone

  tags = {
    Name = "private"
  }
}

#### Internet Gateway ########
resource "aws_internet_gateway" "public" {
  // Only one internet Gateway Per VPC
  # TODO: Check if it is per vpc per az.
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

# Only associate with our public subnet. Every subnet associated with oure public route table, will become public.
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
# access control list is stateless, and controls in the ingress and egress rules for a VPCs/subnets.
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.i.id
  subnet_ids = [aws_subnet.public.id]

  tags = {
    Name = "public"
  }
}

# Adding Ingress Rules #####
resource "aws_network_acl_rule" "public_http" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 100

  from_port  = 80
  to_port    = 80
  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_https" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 200

  from_port  = 443
  to_port    = 443
  cidr_block = "0.0.0.0/0"
}

# Ephemeral ports are used for lots of network traffic, such as downloading things, so these must be allowed both
# inbound and outbound.
resource "aws_network_acl_rule" "public_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 300

  egress     = false
  from_port  = 1024
  to_port    = 65535
  cidr_block = "0.0.0.0/0"
}

# Adding Egress Rules #####
resource "aws_network_acl_rule" "public_http_egress" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 100

  egress     = true
  from_port  = 80
  to_port    = 80
  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_https_egress" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 200

  egress     = true
  from_port  = 443
  to_port    = 443
  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_http_alt_egress" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 300

  egress     = true
  from_port  = 8080
  to_port    = 8080
  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_ephemeral_egress" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 400

  egress     = true
  from_port  = 1024
  to_port    = 65535
  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_any" {
  network_acl_id = aws_network_acl.public.id
  protocol       = "all"
  rule_action    = "allow"
  rule_number    = 500

  egress     = true
  cidr_block = "0.0.0.0/0"
}