# Creating an EC2 instance to test the subnets
terraform {
}

provider "aws" {
  region = "us-west-2"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

# website::tag::1:: Deploy an EC2 Instance.
resource "aws_instance" "public" {
  # website::tag::2:: Run an Ubuntu 18.04 AMI on the EC2 instance.
  ami                    = "ami-0ca5c3bd5a268e7db"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.vpc_public_security_group_id]
  subnet_id = data.terraform_remote_state.vpc.outputs.vpc_public_subnet_id

  # website::tag::3:: When the instance boots, start a web server on port 8080 that responds with "Hello, World!".
  user_data = <<EOF
#!/bin/bash
echo "Hello, World!" > index.html
nohup busybox httpd -f -p 8080 &
EOF
  tags = {
    name = "hello-world-test-public"
  }
}

# website::tag::5:: Output the instance's public IP address.
output "public_ip" {
  value = aws_instance.public.public_ip
}
// Ensure it is in the public subnet
// Create a WebDMZ Security Group
// Create a Key Pair