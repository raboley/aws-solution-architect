data "aws_ami" "wordpress" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*MyWPReadNode*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["478403678109"] # Me
}

resource "aws_launch_configuration" "i" {
  name          = "wordpress_reader"
  image_id      = data.aws_ami.wordpress.id
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.s3_admin.name
  user_data            = file("${path.module}/bootstrap.sh")

  security_groups = [module.vpc.vpc_public_security_group_id]
}

resource "aws_autoscaling_group" "i" {
  name                 = "wordpress-reader"
  launch_configuration = aws_launch_configuration.i.name
  min_size             = 2
  max_size             = 2

  vpc_zone_identifier = [
    module.subnets_a.vpc_public_subnet_id,
    module.subnets_b.vpc_public_subnet_id,
  ]

  target_group_arns         = [aws_lb_target_group.i.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  lifecycle {
    create_before_destroy = true
  }
}