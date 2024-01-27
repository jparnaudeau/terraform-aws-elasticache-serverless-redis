#######################################
# Redis engine Variables
#######################################
variable "name" {
  type        = string
  description = "Elasticache Serverless Redis Cluster Name"
}

variable "description" {
  type        = string
  default     = null
  description = "Description of elasticache serverless redis cluster"
}

variable "major_engine_version" {
  type        = string
  default     = "7"
  description = "Redis engine version"
}

variable "tags" {
  type        = map(string)
  description = "A list of tags to put on resources"
  default     = {}
}

#######################################
# Backups Variables
#######################################
variable "daily_snapshot_time" {
  type        = string
  default     = "00:00"
  description = "The daily start time during which automated backups are initiated if automated backups are enabled. UTC Time"
}

variable "snapshot_retention_limit" {
  type        = number
  default     = 31
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. between 0-35. O means no backups"
}

#######################################
# Network & Security Variables
#######################################
variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC Subnet IDs where the elasticache serverless redis cluster will be deployed"
}

variable "security_group_ids" {
  description = "The list of security group ids to associate to the elasticache serverless redis cluster"
  type        = list(string)
}

variable "kms_key_id" {
  description = "The KMS Key Id to used to encrypt the underlying storage for the elasticache serverless redis cluster"
  type        = string
}

#######################################
# Optional Variables
#######################################
variable "cache_usage_limits" {
  description = "Sets the cache usage limits for storage and ElastiCache Processing Units for the cache. See configuration below."
  type        = any
  default     = null
}

variable "user_group_id" {
  description = "(Optional) The identifier of the UserGroup to be associated with the serverless cache. Available for Redis only. Default is NULL."
  type        = string
  default     = null
}

variable "snapshot_arns_to_restore" {
  description = "The list of ARN(s) of the snapshot that the new serverless cache will be created from. Available for Redis only."
  type        = list(string)
  default     = []
}