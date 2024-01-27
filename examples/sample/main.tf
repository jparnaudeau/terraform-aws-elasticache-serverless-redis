###############################
# Generate a KMS Key
###############################
resource "aws_kms_key" "key" {
  description             = "KMS key for managing encryption for the Elasticache Serverless Redis Cluster"
  deletion_window_in_days = 10
}

###############################
# Deploy Redis users & group
###############################
module "redis_users" {
  source = "../..//users"

  # tags parameters
  tags = var.tags

  # set the KMS Key to use with AWS SecretsManager
  kms_key_arn = aws_kms_key.key.id

  # the default user
  default_user = var.default_user

  # List of users to create
  users = var.users

  # redis group
  group = var.group
}

###############################
# Deploy The Elasticache Serverless Redis Cluster
###############################
module "sandbox" {
  source = "../../"

  name        = "myapp-dev-elasticache-redis"
  description = "Elasticache Serverless for redis cluster"

  # Backups & retention
  daily_snapshot_time      = "04:00"
  snapshot_retention_limit = 31

  # Network & Security
  subnet_ids                          = ["subnet-12345678901234567", "subnet-31415926535897932"]
  security_group_ids                  = ["sg-01123581321345589"]
  elasticache_rest_encryption_key_arn = aws_kms_key.key.id

  # tagging
  tags = var.tags

  # cache usage limits
  # cache_usage_limits = {
  #   data_storage = {
  #     maximum = 10
  #     unit    = "GB"
  #   }
  #   ecpu_per_second = {
  #     maximum = 5
  #   }
  # }

  # Associate the Redis group for iam authentication
  user_group_id = module.redis_users.elasticache_redis_group.id
}


