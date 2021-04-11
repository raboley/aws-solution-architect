//#### Nat Instances vs Nat Gateways ###
//# Nat instances are a VM that acts as a bridge between private subnets, to public subnet to internet gateway.
//# To make a nat instance work you pick an ami from amazon linux that is setup to be a nat gateway
//data "aws_ami" "nat_instance" {
//  most_recent = true
//  owners      = ["amazon"]
//
//  filter {
//    name = "name"
//    values = ["amzn-ami-vpc-nat-hvm-*"]
//  }
//}
//
//# Create the actual instance
//resource "aws_instance" "nat_instance" {
//  ami = data.aws_ami.nat_instance.id
//  instance_type          = "t2.micro"
//  # Then you need to disable Source/Destination checks
//  source_dest_check = false
//
//  subnet_id = aws_subnet.public.id
//}
//
//
//# Then create a route in the default route table.
//resource "aws_route" "nat_instance" {
//  route_table_id = aws_vpc.i.main_route_table_id
//
//  destination_cidr_block = "0.0.0.0/0"
//  instance_id = aws_instance.nat_instance.id
//}
