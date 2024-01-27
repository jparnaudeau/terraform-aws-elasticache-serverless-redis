## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_redis_serverless"></a> [redis\_serverless](#module\_redis\_serverless) | ../../ | n/a |
| <a name="module_redis_users"></a> [redis\_users](#module\_redis\_users) | ../..//users | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS Region | `string` | n/a | yes |
| <a name="input_default_user"></a> [default\_user](#input\_default\_user) | The default user infos | `any` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | The redis group to create | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | a map of tags to put on resources | `map(string)` | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | The list of redis users to create | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Elasticache Serverless Redis cluster ARN. |
| <a name="output_elasticache_redis_group"></a> [elasticache\_redis\_group](#output\_elasticache\_redis\_group) | n/a |
| <a name="output_elasticache_users"></a> [elasticache\_users](#output\_elasticache\_users) | n/a |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Represents the information required for client programs to connect to the Elasticache Serverless Redis cluster. |
| <a name="output_full_engine_version"></a> [full\_engine\_version](#output\_full\_engine\_version) | The name and version number of the engine the serverless cache is compatible with. |
| <a name="output_major_engine_version"></a> [major\_engine\_version](#output\_major\_engine\_version) | The version number of the engine the serverless cache is compatible with. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | Represents the information required for client programs to connect to a cache node. See config below for details. |