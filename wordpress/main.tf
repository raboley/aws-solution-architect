provider "aws" {
  region = "us-west-2"
}

resource "random_string" "i" {
  length  = 5
  special = false
  upper   = false
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

