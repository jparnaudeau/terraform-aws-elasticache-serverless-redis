output "arn" {
  value       = aws_elasticache_serverless_cache.redis.arn
  description = "Elasticache Serverless Redis cluster ARN."
}

output "endpoint" {
  value       = aws_elasticache_serverless_cache.redis.endpoint
  description = "Represents the information required for client programs to connect to the Elasticache Serverless Redis cluster."
}

output "reader_endpoint" {
  value       = aws_elasticache_serverless_cache.redis.reader_endpoint
  description = "Represents the information required for client programs to connect to a cache node. See config below for details."
}

output "full_engine_version" {
  value       = aws_elasticache_serverless_cache.redis.full_engine_version
  description = "The name and version number of the engine the serverless cache is compatible with."
}

output "major_engine_version" {
  value       = aws_elasticache_serverless_cache.redis.major_engine_version
  description = "The version number of the engine the serverless cache is compatible with."
}
