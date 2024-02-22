locals {
  create_default_user                = var.default_user == null ? false : true
  default_user_authent_mode_password = var.default_user.authentication_mode == "password" ? true : false
}
##########################################
# Manage the default user : 
# - generate a random password
# - store it into AWS SecretsManager
# - set the password into the 'default' redis user
##########################################
resource "random_password" "default" {
  count = local.create_default_user && local.default_user_authent_mode_password ? 1 : 0

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
  count = local.create_default_user && local.default_user_authent_mode_password ? 1 : 0

  name        = format(var.default_user.secret_name, var.default_user.user_id)
  description = format(var.default_user.secret_description, var.default_user.user_id)
  kms_key_id  = var.kms_key_id
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "user_secrets_version" {
  count = local.create_default_user && local.default_user_authent_mode_password ? 1 : 0

  secret_id = aws_secretsmanager_secret.default[0].id
  secret_string = jsonencode({
    username = var.default_user.user_name
    password = random_password.default[0].result
    user_arn = aws_elasticache_user.default[0].arn

    }
  )
}

resource "aws_elasticache_user" "default" {
  count = local.create_default_user ? 1 : 0

  user_id       = var.default_user.user_id
  user_name     = var.default_user.user_name # put "default" here
  access_string = var.default_user.access_string
  engine        = "REDIS"
  dynamic "authentication_mode" {
    for_each = !local.default_user_authent_mode_password ? [true] : []

    content {
      type = "iam"
    }
  }
  passwords = local.default_user_authent_mode_password ? [random_password.default[0].result] : null
}
