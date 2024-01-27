## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_user.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user) | resource |
| [aws_elasticache_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user) | resource |
| [aws_elasticache_user_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user_group) | resource |
| [aws_elasticache_user_group_association.assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user_group_association) | resource |
| [aws_secretsmanager_secret.creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.user_secrets_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.creds](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_user"></a> [default\_user](#input\_default\_user) | The default user referenced into the redis group | <pre>object({<br>    user_id             = string<br>    user_name           = string<br>    access_string       = string<br>    secret_description  = string<br>    secret_name         = string<br>    authentication_mode = string<br>  })</pre> | `null` | no |
| <a name="input_group"></a> [group](#input\_group) | The Group to create and to associate to the redis serverless cluster | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS Key Id to use to encrypt secrets in AWS SecretsManager for redis users defined with authentication\_mode = 'password' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A list of tags to put on resources | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | The List of Users to create inside the Elasticache Redis Cluster | <pre>list(object({<br>    user_id             = string<br>    user_name           = string<br>    access_string       = string<br>    secret_description  = string<br>    secret_name         = string<br>    authentication_mode = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elasticache_redis_group"></a> [elasticache\_redis\_group](#output\_elasticache\_redis\_group) | The redis group and its associated users |
| <a name="output_elasticache_users"></a> [elasticache\_users](#output\_elasticache\_users) | The map of elasticache users created |
