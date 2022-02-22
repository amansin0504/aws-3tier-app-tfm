output "sql-dbname" {
    value = aws_db_instance.saferdsdb.db_name
    description = "The instance name for the RDS instance"
}

output "sqldb_private_address" {
  value       = aws_db_instance.saferdsdb.address
  description = "The address assigned for the RDS instance"
}

output "dbusername" {
  value       = aws_db_instance.saferdsdb.username
  description = "SQL db username"
}

output "dbpassword" {
  value       = aws_db_instance.saferdsdb.password
  description = "SQL db Password"
}