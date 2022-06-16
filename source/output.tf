output database_address {
  value       = aws_db_instance.teamcity.address
  description = "The URL or address for the postgres database in address:port format"
}

output database_name {
  value       = aws_db_instance.teamcity.db_name
  description = "The name of the postgres database itself"
}

