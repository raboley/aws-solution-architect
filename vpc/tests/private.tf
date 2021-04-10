resource "aws_instance" "private" {
  # website::tag::2:: Run an Ubuntu 18.04 AMI on the EC2 instance.
  ami                    = "ami-0ca5c3bd5a268e7db"
  instance_type          = "t2.micro"
  security_groups = [data.terraform_remote_state.vpc.outputs.vpc_private_security_group_id]
  subnet_id = data.terraform_remote_state.vpc.outputs.vpc_private_subnet_id

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