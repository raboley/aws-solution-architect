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
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t2.micro"
  name                 = "acloudguru"
  username             = "acloudguru"
  password             = "acloudguru"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  db_subnet_group_name  = aws_db_subnet_group.i.name
  max_allocated_storage = 1000
  copy_tags_to_snapshot = true
}