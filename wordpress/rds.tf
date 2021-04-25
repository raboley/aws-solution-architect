resource "aws_db_subnet_group" "i" {
  name = "rds"
  // Need to have two different AZ subnets for this to work.
  subnet_ids = [
    module.subnets_a.vpc_private_subnet_id,
    module.subnets_b.vpc_private_subnet_id,
  ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "i" {
  allocated_storage = 10
  engine            = "mysql"
  engine_version    = "5.7.33"
  instance_class    = "db.t2.micro"
  name              = "acloudguru"
  username          = "acloudguru"
  password          = "acloudguru"
  //  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.i.name
  vpc_security_group_ids = [module.vpc.vpc_private_security_group_id]
  max_allocated_storage  = 1000
  copy_tags_to_snapshot  = true
  //  option_group_name = aws_db_option_group.i.name
}

resource "aws_db_option_group" "i" {
  name                     = "sa-mysql-8-0"
  option_group_description = "Default option group for mysql 8.0, Managed by Terraform"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}

resource "aws_db_parameter_group" "i" {
  name        = "sa-mysql-8-0"
  description = "Default parameter group for mysql8.0, Managed by Terraform"
  family      = "mysql8.0"

  parameter {
    name  = "activate_all_roles_on_login"
    value = "0"
  }

  //  parameter {
  //    name = "big_tables"
  //    value = "0"
  //  }
  //
  //  parameter {
  //    name = "bind_address"
  //    value = "*"
  //  }
  //
  //  parameter {
  //    name = "binlog_cache_size"
  //    value = "32768"
  //  }
  //
  //  parameter {
  //    name = "binlog_direct_non_transactional_updates"
  //    value = "0"
  //  }
}

output "rds_endpoint" {
  value = aws_db_instance.i.endpoint
}

// terraform import aws_db_instance.i acloudguru
// terraform import aws_db_subnet_group.i default-vpc-0c5f5cbda105123fd