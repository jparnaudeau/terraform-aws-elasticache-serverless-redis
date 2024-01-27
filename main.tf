resource "aws_elasticache_serverless_cache" "redis" {
  # naming parameters & engine settings
  engine               = "redis"
  major_engine_version = var.major_engine_version
  name                 = var.name
  description          = var.description
  tags                 = var.tags

  # Backups
  daily_snapshot_time = var.daily_snapshot_time

  # Security & network
  kms_key_id         = var.kms_key_id
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  # Optional parameters
  dynamic "cache_usage_limits" {
    for_each = var.cache_usage_limits != null ? [true] : []
    content {
      # Data Storage
      dynamic "data_storage" {
        for_each = try(var.cache_usage_limits.data_storage, null) != null ? [true] : []

        content {
          maximum = var.cache_usage_limits.data_storage.maximum
          unit    = var.cache_usage_limits.data_storage.unit
        }
      }

      # ECPU 
      dynamic "ecpu_per_second" {
        for_each = try(var.cache_usage_limits.ecpu_per_second, null) != null ? [true] : []

        content {
          maximum = var.cache_usage_limits.ecpu_per_second.maximum
        }
      }
    }
  }
  snapshot_retention_limit = var.snapshot_retention_limit
  user_group_id            = var.user_group_id
  snapshot_arns_to_restore = var.snapshot_arns_to_restore

}