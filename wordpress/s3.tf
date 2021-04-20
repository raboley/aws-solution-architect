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