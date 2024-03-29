# AWS Elasticache Serverless Redis Terraform module

Terraform module which creates AWS Elasticache Serverless Redis Cluster provided by Terraform AWS provider.

This module covers as well : 

* the deployment of default user, users & group.
* the deployment of a lambda to perform an automated rotation for redis user.

## Versions

| Version | Description |
|---------|-------------|
| 1.0.0| First version of the module.|
| 1.1.0| Add sub-module `automatic-rotation` to deploy a lambda to manage the automatic rotation on the redis users. |


## Usage

### Deploy the Elasticache Serverless Redis cluster

```hcl
module "redis_serverless" {
  source  = "jparnaudeau/elasticache-serverless-redis/aws"
  version = "1.0.0"

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
}
```

### Deploy users & group

```hcl
module "redis_users" {
  source  = "jparnaudeau/elasticache-serverless-redis/aws//users"
  version = "1.0.0"

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
```

and the content of the `terraform.tfvars` : 

```hcl

# define default user
default_user = {
  user_id             = "default-myapp-user"
  user_name           = "default"
  access_string       = "on ~acme::* -@all +@read +@write +cluster|nodes +@connection"
  group               = "myredis-group"
  secret_description  = "The Secret containing credentials for the %s on Elasticache Redis Serverless Cluster"  # %s will be replace by the user_id value
  secret_name         = "/dev/myapp/redis/%s" # %s will be replace by the user_id value
  authentication_mode = "password"
}

# define the list of users to create
users = [
  {
    user_id             = "web-dev-redis"
    user_name           = "web-dev-redis"
    access_string       = "on ~myapp::* -@all +@read +cluster|nodes"
    secret_description  = "Credentials for the user %s on Elasticache Redis Serverless Cluster" # keep one %s. It will be replace by the user_id value
    secret_name         = "/dev/myapp/redis/%s" # keep one %s. # It will be replace by the user_id value
    authentication_mode = "iam"
  },
  {
    user_id             = "app-dev-redis"
    user_name           = "app-dev-redis"
    access_string       = "on ~myapp::* -@all +@read +@write +cluster|nodes +@connection"
    secret_description  = "Credentials for the user %s on Elasticache Redis Serverless Cluster"
    secret_name         = "/dev/myapp/redis/%s"
    authentication_mode = "password"
  },
]

# define the group 
group = "dev-myapp-redis-group"
```

### Deploy Lambda for Automatic Rotation

```hcl
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
  secrets = [
    {
      secret_id       = "/redis/dev/myapp/test-auto-rotation"
      secret_arn      = "arn:aws:secretsmanager:eu-west-1:123456789100:secret:/redis/dev/myapp/test-auto-rotation-0abcdef"
      redis_user_arn  = "arn:aws:elasticache:eu-west-1:123456789100:user:test-auto-rotation"
      redis_user_name = "test-auto-rotation"
      rotation_days   = 60
    },
    {
      secret_id       = "/redis/dev/myapp/test-auto-rotation2"
      secret_arn      = "arn:aws:secretsmanager:eu-west-1:123456789100:secret:/redis/dev/myapp/test-auto-rotation2-6abcdef"
      redis_user_arn  = "arn:aws:elasticache:eu-west-1:123456789100:user:test-auto-rotation2"
      redis_user_name = "test-auto-rotation2"
      rotation_days   = 60
    },
  ]

}

```

> The lambda code used in this module [automatic-rotation/functions/lambda_function.py](automatic-rotation/functions/) is retrieved from the official AWS Sample code : 
https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/blob/master/SecretsManagerElasticacheUserRotation/lambda_function.py

> In the initial code provided by AWS, environment variables `SECRET_ARN` & `USER_NAME` are passed to the lambda function environment variables. These variables permits to verifiy that the secret that will be rotated correspond to the `SECRET_ARN` & that the redis user correspond to the `USER_NAME`. This design implies to deploy one lambda per secret.

> I updated the initial code by using `SECRET_ARNS` & `USER_NAMES` to manage a list of secret ARNs and a list of usernames. It permits to deploy only one lambda, triggered by SecretsManager for each of the secrets for which we want rotate the value.

> during the tests, it could be possible that the lambda fails. It causes an unexpected state in your secret in SecretsManager. You can find a python script [automatic-rotation/utils/delete-awspending-version-of-secret.py](automatic-rotation/utils) to delete the version `AWSPENDING` in your secret. Do it only in case of failure.


## Examples

- [Complete](https://github.com/jparnaudeau/terraform-aws-elasticache-serverless-redis/tree/master/examples/complete) - Complete example which creates Elasticache Serverless Redis Cluster + default user + users + group + the Lambda for automatic password rotation for redis users.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_serverless_cache.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_serverless_cache) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cache_usage_limits"></a> [cache\_usage\_limits](#input\_cache\_usage\_limits) | Sets the cache usage limits for storage and ElastiCache Processing Units for the cache. See configuration below. | `any` | `null` | no |
| <a name="input_daily_snapshot_time"></a> [daily\_snapshot\_time](#input\_daily\_snapshot\_time) | The daily start time during which automated backups are initiated if automated backups are enabled. UTC Time | `string` | `"00:00"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of elasticache serverless redis cluster | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS Key Id to used to encrypt the underlying storage for the elasticache serverless redis cluster | `string` | n/a | yes |
| <a name="input_major_engine_version"></a> [major\_engine\_version](#input\_major\_engine\_version) | Redis engine version | `string` | `"7"` | no |
| <a name="input_name"></a> [name](#input\_name) | Elasticache Serverless Redis Cluster Name | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The list of security group ids to associate to the elasticache serverless redis cluster | `list(string)` | n/a | yes |
| <a name="input_snapshot_arns_to_restore"></a> [snapshot\_arns\_to\_restore](#input\_snapshot\_arns\_to\_restore) | The list of ARN(s) of the snapshot that the new serverless cache will be created from. Available for Redis only. | `list(string)` | `[]` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. between 0-35. O means no backups | `number` | `31` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC Subnet IDs where the elasticache serverless redis cluster will be deployed | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A list of tags to put on resources | `map(string)` | `{}` | no |
| <a name="input_user_group_id"></a> [user\_group\_id](#input\_user\_group\_id) | (Optional) The identifier of the UserGroup to be associated with the serverless cache. Available for Redis only. Default is NULL. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Elasticache Serverless Redis cluster ARN. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Represents the information required for client programs to connect to the Elasticache Serverless Redis cluster. |
| <a name="output_full_engine_version"></a> [full\_engine\_version](#output\_full\_engine\_version) | The name and version number of the engine the serverless cache is compatible with. |
| <a name="output_major_engine_version"></a> [major\_engine\_version](#output\_major\_engine\_version) | The version number of the engine the serverless cache is compatible with. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | Represents the information required for client programs to connect to a cache node. See config below for details. |
