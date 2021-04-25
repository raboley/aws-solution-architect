#### S3
resource "aws_s3_bucket" "code" {
  bucket = "solution-architect-code-${random_string.i.result}"

  tags = {
    Name = "code"
  }
}

resource "aws_s3_bucket" "media" {
  bucket = "solution-architect-media-${random_string.i.result}"

  tags = {
    Name = "media"
  }
}

resource "aws_s3_bucket_policy" "i" {
  bucket = aws_s3_bucket.media.id
  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
        ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.media.id}/*"
        ]
    }
  ]
}
EOF
}