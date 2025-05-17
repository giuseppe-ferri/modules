output "security_group_id" {
  value = aws_security_group.db_sg.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db.name
}