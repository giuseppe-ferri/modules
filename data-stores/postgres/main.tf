resource "aws_db_instance" "example" {
  identifier           = "${var.environment}-postgres-db"
  engine               = "postgres"
  engine_version       = "15.2"
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period
  publicly_accessible  = false
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name = var.db_subnet_group_name
}