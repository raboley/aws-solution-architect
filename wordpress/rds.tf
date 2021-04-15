resource "aws_db_subnet_group" "i" {
  name = "rds"
  // Need to have two different AZ subnets for this to work.
  subnet_ids = [module.vpc.vpc_private_subnet_id]

  tags = {
    Name = "My DB subnet group"
  }
}