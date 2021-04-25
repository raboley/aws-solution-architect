output "s3_cod_id" {
  value = aws_s3_bucket.code.id
}

output "writer_instance_public_ip" {
  value = aws_instance.public.public_ip
}

output "cloudfront_dns_name" {
  value = aws_cloudfront_distribution.media.domain_name
}