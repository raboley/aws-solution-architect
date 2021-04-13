resource "aws_instance" "private" {
  ami                    = "ami-0ca5c3bd5a268e7db"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.vpc_private_security_group_id]
  subnet_id              = module.vpc.vpc_private_subnet_id
  key_name               = "webDMZ"

  # After adding a nat gateway, this private instance will be able to download files from the internet
  # as well, which will make our service work.
  user_data = file("greeter_startup.sh")
  tags = {
    Name = "private"
  }
}

output "private_instance_ip" {
  value = aws_instance.private.private_ip
}