## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3.0 |
| aws       | >= 5.0   |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 5.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                              | Type     |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_efs_file_system.file_system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system)                                   | resource |
| [aws_efs_backup_policy.backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy)                             | resource |
| [aws_efs_mount_target.mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target)                                 | resource |
| [aws_efs_file_system_policy.file_system_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy)               | resource |
| [aws_efs_replication_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_replication_configuration)       | resource |
| [aws_efs_access_point.access_point](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point)                                 | resource |

## Inputs

| Name                                   | Description                                                                                                  | Type                  | Default            | Required |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------|-----------------------|--------------------|:--------:|
| availability_zone                      | AZ for One Zone storage (e.g. `us-west-2a`). Required when `one_zone_storage = true`                        | `string`              | `null`             | no       |
| bypass_policy_lockout_safety_check     | Whether to bypass the `aws:PrincipalArn` lockout safety check when setting the file system policy            | `bool`                | `false`            | no       |
| creation_token                         | Unique token for idempotent EFS file system creation                                                         | `string`              | `null`             | no       |
| enable_backup                          | Enable automatic backups via AWS Backup                                                                      | `bool`                | `true`             | no       |
| encrypted                              | Whether to enable encryption at rest for the EFS file system                                                 | `bool`                | `true`             | no       |
| file_system_policy                     | JSON IAM policy document to attach to the EFS file system. If null, no policy is created                    | `string`              | `null`             | no       |
| kms_key_id                             | KMS key ARN for encryption. Defaults to the EFS service key                                                  | `string`              | `null`             | no       |
| mount_targets                          | Mount target configurations. Each entry requires `subnet_id` and optional `security_group_ids`               | `list(object({...}))` | `[]`               | no       |
| one_zone_storage                       | Enable One Zone storage (single AZ, lower cost). Requires `availability_zone` and a single subnet            | `bool`                | `false`            | no       |
| performance_mode                       | The file system performance mode. Valid values: `generalPurpose` or `maxIO`                                  | `string`              | `"generalPurpose"` | no       |
| posix_gid                              | POSIX group ID for the EFS access point                                                                      | `number`              | n/a                | yes      |
| posix_uid                              | POSIX user ID for the EFS access point                                                                       | `number`              | n/a                | yes      |
| provisioned_throughput_in_mibps        | Provisioned throughput in MiB/s. Required when `throughput_mode` is `provisioned`                           | `number`              | `null`             | no       |
| replication_destination                | Replication destination configuration. If null, replication is not configured                                | `object({...})`       | `null`             | no       |
| root_directory_path                    | Root directory path exposed by the access point                                                              | `string`              | `"/"`              | no       |
| root_directory_permissions             | POSIX permissions for the root directory                                                                     | `string`              | `"0755"`           | no       |
| tags                                   | A map of tags to apply to all resources                                                                      | `map(string)`         | `{}`               | no       |
| throughput_mode                        | The throughput mode for the file system. Valid values: `bursting`, `provisioned`, or `elastic`               | `string`              | `"bursting"`       | no       |
| transition_to_archive                  | Transition files to Archive storage. Not supported for One Zone                                              | `string`              | `"AFTER_14_DAYS"`  | no       |
| transition_to_ia                       | Transition files to Infrequent Access storage                                                                | `string`              | `"AFTER_1_DAY"`    | no       |
| transition_to_primary_storage_class    | Transition files back to primary storage class after access. Valid value: `AFTER_1_ACCESS`. Set to null to disable | `string`         | `"AFTER_1_ACCESS"` | no       |

## Outputs

| Name                          | Description                                                                       |
|-------------------------------|-----------------------------------------------------------------------------------|
| id                            | EFS file system ID                                                                |
| arn                           | EFS file system ARN                                                               |
| dns_name                      | EFS file system DNS name                                                          |
| access_point_id               | EFS access point ID                                                               |
| access_point_arn              | EFS access point ARN                                                              |
| mount_target_ids              | List of EFS mount target IDs                                                      |
| file_system_policy_id         | EFS file system ID that the policy is attached to (null if no policy configured)  |
| replication_configuration_id  | Source EFS file system ID of the replication configuration (null if not configured) |

## License

Apache 2 Licensed. See [LICENSE](https://github.com/TechHoldingLLC/terraform-aws-efs/blob/main/LICENSE) for full details.
