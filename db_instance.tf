resource "aws_security_group" "rds_default_security_group" {
  name        = "rds_default_security_group"
  description = "rds default security group"
#  vpc_id      = aws_vpc.default.id
   vpc_id     = local.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["172.31.32.0/20", "172.31.64.0/20", "172.31.96.0/20"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_default_security_group"
  }
}

resource "aws_db_instance" "db" {
  engine            = var.rds_engine
  engine_version    = var.rds_engine_version
  identifier        = var.rds_identifier
  instance_class    = var.rds_instance_type
  allocated_storage = var.rds_storage_size
  name              = var.rds_db_name
  username          = var.rds_admin_user
  password          = var.rds_admin_password
  publicly_accessible    = var.rds_publicly_accessible
  vpc_security_group_ids = [aws_security_group.rds_default_security_group.id]
#  vpc_security_group_ids = [aws_security_group.docker_default_ec2_security_group.id]
  final_snapshot_identifier = "rds-db-backup"
  skip_final_snapshot       = true
  multi_az               = var.multi_az

  # commented : if there is no default subnet, this will give us an error
  #db_subnet_group_name   = "rds_test"

  tags = {
    Name = "Postgres Database in ${var.aws_region}"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group-${count.index}"
  count      = length(var.azs)
  subnet_ids = element(split(",", join(",", aws_subnet.private.*.id)), count.index)

}

output "postgress-address" {
  value = "address: aws_db_instance.db.address"
}