resource "aws_instance" "private" {
  ami                    = "ami-0ca5c3bd5a268e7db"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.vpc_private_security_group_id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_id
  key_name               = "webDMZ"

  # Internet Connectivity won't work to allow us to run go-greeter, so need to add a nat gateway.
  //  user_data = <<EOF
  //#!/bin/bash
  //echo "Hello, World!" > index.html
  //nohup busybox httpd -f -p 8080 &
  //EOF

  # After adding nat gateway make it work like my other service does
  user_data = file("greeter_startup.sh")
  tags = {
    Name = "private"
  }
}

output "private_instance_ip" {
  value = aws_instance.private.private_ip
}