resource "aws_ssm_parameter" "cloudx_mysql_password" {
  name        = var.ssm_db_password_paramname
  description = var.ssm_db_password_paramname_description
  type        = "SecureString"
  value       = var.mysql_database_password
  tags        = merge(var.common_project_tags, var.ssm_db_password_paramname_tags)
}

resource "aws_ssm_parameter" "cloudx_mysql_user" {
  name        = var.ssm_db_user_paramname
  description = var.ssm_db_user_paramname_description
  type        = "SecureString"
  value       = var.mysql_database_user
  tags        = merge(var.common_project_tags, var.ssm_db_user_paramname_tags)
}

resource "aws_db_subnet_group" "cloudx_ghost_mysql" {
  description = var.ghost_mysql_db_subnet_group.description
  name        = var.ghost_mysql_db_subnet_group.name
  subnet_ids  = aws_subnet.databases.*.id
  tags        = merge(var.common_project_tags, var.ghost_mysql_db_subnet_group.tags)
}


resource "aws_db_instance" "cloudx_ghost_mysql" {
  db_name              = var.mysql_database_name
  allocated_storage    = var.rds_db_instantce_params.allocated_storage
  storage_type         = var.rds_db_instantce_params.storage_type
  engine               = var.rds_db_instantce_params.engine
  engine_version       = var.rds_db_instantce_params.engine_version
  instance_class       = var.rds_db_instantce_params.instance_class
  username             = var.mysql_database_user
  password             = var.mysql_database_password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.cloudx_ghost_mysql.name

  vpc_security_group_ids = [([for x in aws_security_group.cloudx_security_groups :
  x.id if x.name == var.mysql_db_security_group_name][0])]

  tags = merge(var.common_project_tags, var.rds_db_instantce_params.tags)
}
