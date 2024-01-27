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
