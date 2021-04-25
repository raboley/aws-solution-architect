output "vpc_id" {
  value = aws_vpc.i.id
}

output "vpc_cidr" {
  value = aws_vpc.i.cidr_block
}

output "vpc_internet_gateway_id" {
  value = aws_internet_gateway.i.id
}

output "vpc_public_security_group_id" {
  value = aws_security_group.public.id
}

output "vpc_private_security_group_id" {
  value = aws_security_group.private.id
}
