##########################################
# for each user defined with authentication_mode = "password" : 
# - generate a random password
# - store it into AWS SecretsManager
# - create the redis user
##########################################
resource "random_password" "creds" {
  for_each = { for user in var.users : user.user_id => user if user.authentication_mode == "password" }

  length           = 16
  special          = true
  upper            = true
  lower            = true
  min_upper        = 1
  min_numeric      = 1
  min_special      = 3
  override_special = "!#$%*-_+"

}

resource "aws_secretsmanager_secret" "creds" {
  for_each = { for user in var.users : user.user_id => user if user.authentication_mode == "password" }

  name        = format(each.value.secret_name, each.value.user_id)
  description = format(each.value.secret_description, each.value.user_id)
  kms_key_id  = var.kms_key_id
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "creds" {
  for_each  = { for user in var.users : user.user_id => user if user.authentication_mode == "password" }
  secret_id = aws_secretsmanager_secret.creds[each.key].id

  secret_string = jsonencode({
    username = each.value.user_name
    password = random_password.creds[each.key].result
    user_arn = aws_elasticache_user.user[each.key].arn
    }
  )
}

resource "aws_elasticache_user" "user" {
  for_each      = { for user in var.users : user.user_id => user }
  user_id       = each.key
  user_name     = each.value.user_name # with iam authentication, need to be = to user_id
  access_string = each.value.access_string
  engine        = "REDIS"

  dynamic "authentication_mode" {
    for_each = each.value.authentication_mode == "iam" ? [true] : []

    content {
      type = "iam"
    }
  }
  passwords = each.value.authentication_mode == "password" ? [random_password.creds[each.key].result] : null
}

######################################
# Create redis group. Possible only if we have a default user
######################################
resource "aws_elasticache_user_group" "group" {
  count = local.create_default_user ? 1 : 0

  engine        = "REDIS"
  user_group_id = var.group
  user_ids      = [aws_elasticache_user.default[0].user_id]

  lifecycle {
    ignore_changes = [user_ids]
  }
}

######################################
# for each redis user that is not a default user,
# add it into the group
######################################
resource "aws_elasticache_user_group_association" "assoc" {
  for_each      = { for user in var.users : user.user_id => user if local.create_default_user }
  user_group_id = aws_elasticache_user_group.group[0].user_group_id
  user_id       = aws_elasticache_user.user[each.key].user_id
}