resource "aws_subnet" "public" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  # Auto assign public IPs to EC2 instances on launch in the public subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.availability_zone}-public"
  }
}

#### Route Tables ########
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.availability_zone}-public"
  }
}

# Only associate with our public subnet. Every subnet associated with oure public route table, will become public.
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route" "public_out_ipv4" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.vpc_internet_gateway_id
}

resource "aws_route" "public_out_ipv6" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = var.vpc_internet_gateway_id
}

#### Security Groups ########
resource "aws_security_group" "public" {
  vpc_id = var.vpc_id

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

#### Nat Gateways ############
# This will allow our private subnet to access the internet to download stuff.
resource "aws_eip" "nat_gateway" {}

resource "aws_nat_gateway" "i" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id
}

data "aws_vpc" "i" {
  id = var.vpc_id
}

#### ACL #####################
# access control list is stateless, and controls in the ingress and egress rules for a VPCs/subnets.
resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
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
