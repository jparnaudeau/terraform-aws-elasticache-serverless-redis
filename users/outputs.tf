output "elasticache_redis_group" {
  description = "The redis group and its associated users"
  value = local.create_default_user == true ? {
    arn                     = aws_elasticache_user_group.group[0].arn
    id                      = aws_elasticache_user_group.group[0].id
    default_user_arn        = try(aws_elasticache_user.default[0].arn, "")
    default_user_secret_arn = local.default_user_authent_mode_password ? try(aws_secretsmanager_secret.default[0].arn, "") : "not defined"
    users                   = [for u in var.users : u.user_id]
  } : null
}

output "elasticache_users" {
  description = "The map of elasticache users created"
  value = { for k, v in { for user in var.users : user.user_id => user } : k => {
    username   = k
    arn        = aws_elasticache_user.user[k].arn
    secret_id  = v.authentication_mode == "password" ? aws_secretsmanager_secret.creds[k].id : "not-defined"
    secret_arn = v.authentication_mode == "password" ? aws_secretsmanager_secret.creds[k].arn : "not-defined"
    }
  }
}