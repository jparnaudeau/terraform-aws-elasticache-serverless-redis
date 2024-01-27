output "arn" {
  value       = module.sandbox.arn
  description = "Elasticache Serverless Redis cluster ARN."
}

output "endpoint" {
  value       = module.sandbox.endpoint
  description = "Represents the information required for client programs to connect to the Elasticache Serverless Redis cluster."
}

output "reader_endpoint" {
  value       = module.sandbox.reader_endpoint
  description = "Represents the information required for client programs to connect to a cache node. See config below for details."
}

output "full_engine_version" {
  value       = module.sandbox.full_engine_version
  description = "The name and version number of the engine the serverless cache is compatible with."
}

output "major_engine_version" {
  value       = module.sandbox.major_engine_version
  description = "The version number of the engine the serverless cache is compatible with."
}

output "elasticache_redis_group" {
  value = module.redis_users.elasticache_redis_group
}

output "elasticache_users" {
  value = module.redis_users.elasticache_users
}