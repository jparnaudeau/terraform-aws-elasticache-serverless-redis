# Module: terraform-aws-elasticache-serverless-redis
# Variables
#
#######################################
# Rotation Lambda Variables
#######################################
variable "name_patern" {
  type        = string
  description = "The pattern to use for generating the name"
  default     = "%s-elasticache-redis-auto-password-rotation"
}

variable "kms_key_id" {
  description = "The KMS Key Id used to encrypt secrets in AWS SecretsManager"
  type        = string
  default     = null
}

variable "tags" {
  description = "A Map of tag to put on the resources deployed by this module"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "The list of subnet Ids in which the lambda will be deployed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "The list of security group Ids to attached to the lambda"
  type        = list(string)
}

variable "timeout" {
  description = "The tiemout to set on the Lambda function. Updating a redis user take time. Default is 10 min."
  type        = number
  default     = 600
}

variable "secrets" {
  description = "The list of secrets for which the lambda will be associated"
  type = list(object({
    secret_id       = string
    secret_arn      = string
    rotation_days   = number
    redis_user_arn  = string
    redis_user_name = string
  }))
  default = []
}
