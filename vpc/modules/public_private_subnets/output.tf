

output "vpc_public_subnet_id" {
  value = aws_subnet.public.id
}

output "vpc_private_subnet_id" {
  value = aws_subnet.private.id
}
