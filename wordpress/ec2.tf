data "aws_ami" "i" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_iam_instance_profile" "s3_admin" {
  name = "s3_Admin"
  role = module.iam_s3admin.iam_role_name
}

resource "aws_instance" "public" {
  //  ami                    = "ami-0ca5c3bd5a268e7db"
  ami                    = data.aws_ami.i.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.vpc_public_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.s3_admin.name

  subnet_id = module.subnets_a.vpc_public_subnet_id
  key_name  = "webDMZ"

  user_data = file("${path.module}/wordpress.sh")
  tags = {
    Name = "MyGoldenImage"
  }
}

// // Doesn't work on darwin_arm64
//data "template_cloudinit_config" "i" {
//  gzip = false
//  base64_encode = false
//
//  part {
//    content_type = "text/x-shellscript"
//    content = <<-EOF
//    #!/bin/bash
//    echo 'cloud_front_dns="${aws_cloudfront_distribution.media.domain_name}"' > /opt/cloud_front_dns
//EOF
//  }
//
//  part {
//    content_type = "text/x-shellscript"
//    content = file("wordpress.sh")
//  }
//}

// Fill in DB credentials for wordpress site in the /var/www/html/wp-config.php
// Make a post with an upload image
// Copy the uploads
//  aws s3 cp --recursive /var/www/html/wp-content/uploads s3://solution-architect-media-suzoz
// update the /var/www/html/.htaccess file to have the correct domain name for the cloud front
// Update /etc/httpd/conf/httpd.conf to AllowOverride All
// Copy the code
//  aws s3 cp --recursive /var/www/html s3://solution-architect-code-suzoz
// service httpd restart
// The image should be hosted on cloudfront now
// edit the crontab vim /etc/crontab
// */1 * * * * root aws s3 sync --delete s3://solution-architect-code-suzoz /var/www/html
// add a file to bucket
// restart crontab
// service crond restart
// ls the /var/www/html directory (I put a png up there and it too a minute or two to sync)

// Now in aws gui create a golden image from this
// MyWPReadNode

// In the writer node reverse the crontab to sync the local dir with the s3 bucket.
// vim /etc/crontab
// */1 * * * * root aws s3 sync --delete /var/www/html s3://solution-architect-code-suzoz
// */1 * * * * root aws s3 sync --delete /var/www/html/wp-content/uploads s3://solution-architect-media-suzoz

// Can create a file to test this.
//
