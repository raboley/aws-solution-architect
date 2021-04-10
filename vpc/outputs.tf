output "vpc_public_subnet_id" {
  value = aws_subnet.public.id
}

output "vpc_private_subnet_id" {
  value = aws_subnet.private.id
}

output "vpc_id" {
  value = aws_vpc.i.id
}

output "vpc_public_security_group_id" {
  value = aws_security_group.public.id
}

output "vpc_private_security_group_id" {
  value = aws_security_group.private.id
}
