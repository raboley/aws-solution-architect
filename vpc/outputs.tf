output "vpc_id" {
  value = aws_vpc.i.id
}

output "vpc_cidr" {
  value = aws_vpc.i.cidr_block
}

