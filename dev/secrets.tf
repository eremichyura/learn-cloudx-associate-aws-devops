resource "aws_secretsmanager_secret" "rds" {
  name                    = "rds_credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode(var.rds_creds)
}

data "aws_secretsmanager_secret" "rds" {
  name = aws_secretsmanager_secret.rds.name
}

data "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}

