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
  # source  = "jparnaudeau/elasticache-serverless-redis/aws//users"
  # version = "1.1.0"

  # tags parameters
  tags = var.tags

  # set the KMS Key to use with AWS SecretsManager if you have redis user defined with authentication_mode = 'password'
  kms_key_id = aws_kms_key.key.id

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
module "redis_serverless" {
  source = "../../"
  # source  = "jparnaudeau/elasticache-serverless-redis/aws"
  # version = "1.0.0"

  name        = "myapp-dev-elasticache-redis"
  description = "Elasticache Serverless for redis cluster"

  # Backups & retention
  daily_snapshot_time      = "22:00"
  snapshot_retention_limit = 10

  # Network & Security
  subnet_ids         = ["subnet-12345678901234567", "subnet-31415926535897932"]
  security_group_ids = ["sg-01123581321345589"]
  kms_key_id         = aws_kms_key.key.id

  # tagging
  tags = var.tags

  # cache usage limits
  cache_usage_limits = {
    # data_storage = {
    #   maximum = 100
    #   unit    = "GB"
    # }
    ecpu_per_second = {
      maximum = 5
    }
  }

  # Associate the Redis group for iam authentication
  user_group_id = module.redis_users.elasticache_redis_group.id

  # use the snapshot to initiate data cluster
  #snapshot_arns_to_restore = [""]
}

###############################
# Deploy a Security Group for our Lambda
# and open the flow on port 6379 & 6380
###############################
module "security_group" {
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to an other resource"
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "myapp-auto-password-rotation-sg"
  description = "Securtiy Group associated to the Lambda for the password rotation"
  vpc_id      = "vpc-31415926535897932"

  # egress
  egress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = 6
      description = "Allow Outbound TCP Communication on AWS Elasticache API"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = "myapp-auto-password-rotation-sg"
  }
}

###############################
# Deploy The lambda function ready to rotate secrets
###############################
module "redis-password-rotation" {
  source = "../..//automatic-rotation"
  # source  = "jparnaudeau/elasticache-serverless-redis/aws//automatic-rotation"
  # version = "1.1.0"

  depends_on = [module.redis_users]

  name_patern = "myapp-auto-password-rotation-%s" # used in lambda name & role name. Keep one %s 
  kms_key_id  = aws_kms_key.key.id

  subnet_ids         = ["subnet-31415926535897932"]
  security_group_ids = [module.security_group.security_group_id]

  # you can rotate password only for redis users defined with 'authentication_mode' = password
  secrets = [for k, v in { for user in var.users : user.user_id => user } :
    {
      secret_id       = format(v.secret_name, k)
      secret_arn      = module.redis_users.elasticache_users["app-dev-redis"].secret_arn
      redis_user_arn  = module.redis_users.elasticache_users["app-dev-redis"].arn
      redis_user_name = k
      rotation_days   = 60
    } if v.authentication_mode == "password"
  ]

}
