resource "aws_db_subnet_group" "cloudx_ghost_mysql" {
  description = var.ghost_mysql_db_subnet_group.description
  name        = var.ghost_mysql_db_subnet_group.name
  subnet_ids  = aws_subnet.databases.*.id
  tags        = merge(var.common_project_tags, var.ghost_mysql_db_subnet_group.tags)
}

resource "aws_db_instance" "cloudx_ghost_mysql" {
  db_name              = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_name
  username             = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_user
  password             = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_password
  allocated_storage    = var.rds_db_instantce_params.allocated_storage
  storage_type         = var.rds_db_instantce_params.storage_type
  engine               = var.rds_db_instantce_params.engine
  engine_version       = var.rds_db_instantce_params.engine_version
  instance_class       = var.rds_db_instantce_params.instance_class
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.cloudx_ghost_mysql.name

  vpc_security_group_ids = [([for x in aws_security_group.cloudx_security_groups :
  x.id if x.name == var.mysql_db_security_group_name][0])]

  tags = merge(var.common_project_tags, var.rds_db_instantce_params.tags)
  depends_on = [
    aws_secretsmanager_secret.rds
  ]
}
