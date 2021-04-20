# Creating an EC2 instance to test the subnets
terraform {
}

variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = var.region
}


module "vpc" {
  source = "../"

}

locals {
  # TODO have this split by number of AZs.
  # Ex. 2 subnets per Availability Zone.
  subnet_cidrs = cidrsubnets(module.vpc.vpc_cidr, 3, 3, 3, 3, 3, 3)
}

module "subnets_a" {
  source = "../modules/public_private_subnets/"

  vpc_id                  = module.vpc.vpc_id
  vpc_internet_gateway_id = module.vpc.vpc_internet_gateway_id
  availability_zone       = "${var.region}a"
  private_subnet_cidr     = local.subnet_cidrs[0]
  public_subnet_cidr      = local.subnet_cidrs[1]
}

module "subnets_b" {
  source = "../modules/public_private_subnets/"

  vpc_id                  = module.vpc.vpc_id
  vpc_internet_gateway_id = module.vpc.vpc_internet_gateway_id
  availability_zone       = "${var.region}b"
  private_subnet_cidr     = local.subnet_cidrs[2]
  public_subnet_cidr      = local.subnet_cidrs[3]
}

resource "aws_instance" "public" {
  ami                    = "ami-0ca5c3bd5a268e7db"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.subnets_a.vpc_public_security_group_id]

  subnet_id = module.subnets_a.vpc_public_subnet_id
  key_name  = "webDMZ"

  user_data = file("greeter_startup.sh")
  tags = {
    Name = "public"
  }
}

output "public_ip" {
  value = aws_instance.public.public_ip
}

// Create a Key Pair
resource "aws_key_pair" "i" {
  key_name   = "13-inch-mac"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDr01uV6tTwbiuangAIsa05u7FrpZO2ouEQDTcXXy7q9WS2FNmJOEe7YliOa8os6evto9E25HeBV6Q1is03eTVGvIJmRC793OrTnth+xtamZ6jbQiGI+KDBUkV76ozOF0p5ygP5aX58R//685pzzyOzhCSrHSf/Hbs5bKlwqnvUR8Nf7FpO/Jp/gIrrU+kdxAF0YK7doldALg2U7qwOBtSYN9XX8xu+Cp5roaGXx92f20XRVIv+xAZdMl7P20ljWzWd0cAzlX/dA0o5ROgI+dpbp6F4kRFyxdpJfRCWvK1H5BrTOuiuRTbG/E3UHsab0fLllN6d20Gv/ou9Oy7bCju6wyYPjXWiLArd+1QamqKCTU/p3iCWppt+vl/igAGzUHfYPB3gZ6WK+HJrAfIrG7ft6vgVXLCIxV6g/+VnBmKbxE5vnLx+w5kUi+KsLyyiJ1vheoJsSgZ3j6BP0MkBDwq25VLrQfYRqLQFJ8DfcVF7TbpP+IwR7S0JFxRTLX6iPP3jE4PfK9uriqPc+QktV3upnwYaaRu2vRevm66eaXhuoiTdNi2bC/g7CmEBUQ72nQ19QHJYBYEuLmzACkfYtI3rtgZsEp/nBPY2LB3BH0ROYDcGZPOZ+rwfyGVEVofsmto1eNR1NBPMhRKfC9cw8HoE92t2sNgFMxzFts4GYgv9hw== raboley@gmail.com"
}