provider "aws" {
  region = "us-west-2"
}

resource "random_string" "i" {
  length  = 5
  special = false
  upper   = false
}

#### S3
resource "aws_s3_bucket" "code" {
  bucket = "solution-architect-code-${random_string.i.result}"

  tags = {
    Name = "code"
  }
}

resource "aws_s3_bucket" "media" {
  bucket = "solution-architect-media-${random_string.i.result}"
  acl    = "public-read"

  tags = {
    Name = "media"
  }
}

locals {
  # This is a local because by default, portal will create origin ID with a syntax like this.
  media_origin_id = "S3-${aws_s3_bucket.media.id}"
}
#### Cloud front
resource "aws_cloudfront_distribution" "media" {
  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    target_origin_id       = local.media_origin_id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  origin {
    domain_name = aws_s3_bucket.media.bucket_domain_name
    origin_id   = local.media_origin_id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

