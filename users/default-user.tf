##########################################
# Manage the default user : 
# - generate a random password
# - store it into AWS SecretsManager
# - set the password into the 'default' redis user
##########################################
resource "random_password" "default" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  min_upper        = 1
  min_numeric      = 1
  min_special      = 3
  override_special = "!#$%*-_+"

}

resource "aws_secretsmanager_secret" "default" {
  name        = var.default_user.secret_name
  description = var.default_user.secret_description
  kms_key_id  = var.kms_key_arn
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "user_secrets_version" {
  secret_id = aws_secretsmanager_secret.default.id

  secret_string = jsonencode({
    user_name = var.default_user.user_name
    password  = random_password.default.result
    }
  )
}

resource "aws_elasticache_user" "default" {
  user_id       = var.default_user.user_id
  user_name     = var.default_user.user_name
  access_string = var.default_user.access_string
  engine        = "REDIS"
  passwords     = [random_password.default.result]
}
