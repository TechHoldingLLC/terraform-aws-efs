##################
# variables.tf ##
#################

variable "availability_zone" {
  description = "AZ for One Zone storage (e.g. `us-west-2a`). Required when `one_zone_storage = true`."
  type        = string
  default     = null
}

variable "bypass_policy_lockout_safety_check" {
  description = "Whether to bypass the `aws:PrincipalArn` lockout safety check when setting the file system policy."
  type        = bool
  default     = false
}

variable "creation_token" {
  description = "Unique token for idempotent EFS file system creation."
  type        = string
  default     = null
}

variable "enable_backup" {
  description = "Enable automatic backups via AWS Backup."
  type        = bool
  default     = true
}

variable "encrypted" {
  description = "Whether to enable encryption at rest for the EFS file system."
  type        = bool
  default     = true
}

variable "file_system_policy" {
  description = "JSON IAM policy document to attach to the EFS file system. If null, no policy is created."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ARN for encryption. Defaults to the EFS service key."
  type        = string
  default     = null
}

variable "mount_targets" {
  description = "Mount target configurations. Each entry requires `subnet_id` and optional `security_group_ids`."
  type = list(object({
    subnet_id          = string
    security_group_ids = optional(list(string), [])
  }))
  default = []
}

variable "one_zone_storage" {
  description = "Enable One Zone storage (single AZ, lower cost). Requires `availability_zone` and a single subnet in `mount_targets`."
  type        = bool
  default     = false
}

variable "performance_mode" {
  description = "The file system performance mode. Valid values: `generalPurpose` or `maxIO`."
  type        = string
  default     = "generalPurpose"
}

variable "create_access_point" {
  description = "Whether to create an EFS access point. When true, `posix_uid` and `posix_gid` are required."
  type        = bool
  default     = true
}

variable "posix_gid" {
  description = "POSIX group ID for the EFS access point. Required when `create_access_point = true`."
  type        = number
  default     = null
}

variable "posix_uid" {
  description = "POSIX user ID for the EFS access point. Required when `create_access_point = true`."
  type        = number
  default     = null
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput in MiB/s. Required when `throughput_mode` is `provisioned`."
  type        = number
  default     = null
}

variable "replication_destination" {
  description = "Replication destination configuration. If null, replication is not configured."
  type = object({
    availability_zone_name = optional(string)
    file_system_id         = optional(string)
    kms_key_id             = optional(string)
    region                 = optional(string)
  })
  default = null
}

variable "root_directory_path" {
  description = "Root directory path exposed by the access point."
  type        = string
  default     = "/"
}

variable "root_directory_permissions" {
  description = "POSIX permissions for the root directory."
  type        = string
  default     = "0755"
}

variable "throughput_mode" {
  description = "The throughput mode for the file system. Valid values: `bursting`, `provisioned`, or `elastic`."
  type        = string
  default     = "bursting"
}

variable "transition_to_archive" {
  description = "Transition files to Archive storage. Only supported when `throughput_mode` is `elastic` and `one_zone_storage` is false. Valid values: `AFTER_1_DAY`, `AFTER_7_DAYS`, `AFTER_14_DAYS`, `AFTER_30_DAYS`, `AFTER_60_DAYS`, `AFTER_90_DAYS`. Set to null to disable."
  type        = string
  default     = null
}

variable "transition_to_ia" {
  description = "Transition files to Infrequent Access. Valid values: `AFTER_1_DAY`, `AFTER_7_DAYS`, `AFTER_14_DAYS`, `AFTER_30_DAYS`, `AFTER_60_DAYS`, `AFTER_90_DAYS`."
  type        = string
  default     = "AFTER_1_DAY"
}

variable "transition_to_primary_storage_class" {
  description = "Transition files back to primary storage class after access. Valid value: `AFTER_1_ACCESS`. Set to null to disable."
  type        = string
  default     = "AFTER_1_ACCESS"
}
