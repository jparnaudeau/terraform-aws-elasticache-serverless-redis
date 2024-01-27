output "elasticache_redis_group" {
  description = "The redis group and its associated users"
  value = {
    arn              = aws_elasticache_user_group.group.arn,
    id               = aws_elasticache_user_group.group.id,
    default_user_arn = aws_elasticache_user.default.arn
    users            = [for u in var.users : u.user_id]
  }
}

output "elasticache_users" {
  description = "The map of elasticache users created"
  value = { for k, v in { for user in var.users : user.user_id => user } : k => {
    arn = aws_elasticache_user.user[k].arn,
  } }
}