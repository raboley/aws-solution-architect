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

  user_data = file("wordpress.sh")
  tags = {
    Name = "MyGoldenImage"
  }
}