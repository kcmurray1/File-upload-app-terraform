
output "db_endpoint" {
    value = aws_db_instance.mysql-db.address
}

output "db_username" {
    value = var.db_username
}

output "db_password" {
    value = var.db_password
}
