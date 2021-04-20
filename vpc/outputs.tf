output "vpc_id" {
  value = aws_vpc.i.id
}

output "vpc_cidr" {
  value = aws_vpc.i.cidr_block
}

output "vpc_internet_gateway_id" {
  value = aws_internet_gateway.i.id
}

