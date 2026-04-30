# terraform-aws-efs — Usage Examples

This module creates an AWS EFS file system with optional backup, mount targets, access point, file system policy, and replication configuration.

---

## Example 1: Basic EFS (Defaults)

Minimal setup using default values — encrypted, bursting throughput, backups enabled, IA transition after 1 day.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  creation_token = "my-app-efs"

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]
}
```

---

## Example 2: Encrypted EFS with Custom KMS Key

Use a customer-managed KMS key for encryption instead of the default EFS service key.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  creation_token = "my-app-efs"
  encrypted      = true
  kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]
}
```

---

## Example 3: Provisioned Throughput Mode

Use provisioned throughput when your workload requires consistent, predictable performance.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 256

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    },
    {
      subnet_id          = "subnet-0def456789abc1234"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]
}
```

---

## Example 4: One Zone Storage (Single AZ, Lower Cost)

One Zone storage keeps data in a single AZ. Ideal for dev/test or non-critical workloads where cost matters more than multi-AZ durability. Archive lifecycle policy is automatically skipped for One Zone.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  one_zone_storage   = true
  availability_zone  = "us-east-1a"

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"  # Must be in us-east-1a
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]
}
```

---

## Example 5: Custom Lifecycle Policies

Control when files move between Standard, Infrequent Access, Archive, and back to primary storage.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  throughput_mode = "elastic"  # Required for transition_to_archive

  transition_to_ia                    = "AFTER_7_DAYS"   # Move to IA after 7 days of inactivity
  transition_to_archive               = "AFTER_30_DAYS"  # Move to Archive after 30 days in IA (requires elastic throughput)
  transition_to_primary_storage_class = "AFTER_1_ACCESS" # Move back to Standard on first access

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]
}
```

To disable a lifecycle policy, set it to `null`:

```hcl
  transition_to_ia                    = null  # Disable IA transition
  transition_to_primary_storage_class = null  # Disable primary storage class transition
```

---

## Example 6: EFS File System Policy

Attach a resource-based IAM policy to restrict access to the file system. The example below allows only a specific IAM role to mount and write.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]

  file_system_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowMountAndWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/my-app-role"
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = "*"
      }
    ]
  })

  # Set to true only if you need to apply a policy that could lock you out.
  # Use with extreme caution.
  bypass_policy_lockout_safety_check = false
}
```

---

## Example 7: Cross-Region Replication

Replicate your EFS file system to another AWS region for disaster recovery. The destination file system is created automatically if `file_system_id` is omitted.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  posix_uid = 1000
  posix_gid = 1000

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]

  replication_destination = {
    region     = "eu-west-1"
    kms_key_id = "arn:aws:kms:eu-west-1:123456789012:key/mrk-xyz789"
  }
}
```

To replicate to an existing EFS file system:

```hcl
  replication_destination = {
    region         = "eu-west-1"
    file_system_id = "fs-0abc123456def7890"
  }
```

To replicate within the same region to a specific AZ (One Zone destination):

```hcl
  replication_destination = {
    availability_zone_name = "us-east-1b"
  }
```

---

## Example 8: Full Production Setup

A complete configuration combining encryption, provisioned throughput, backups, lifecycle policies, file system policy, and cross-region replication.

```hcl
module "efs" {
  source = "path/to/terraform-aws-efs"

  creation_token  = "prod-app-efs"
  encrypted       = true
  kms_key_id      = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"
  performance_mode = "generalPurpose"

  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 512

  enable_backup = true

  transition_to_ia                    = "AFTER_7_DAYS"
  # transition_to_archive is not supported with provisioned throughput mode; use elastic throughput to enable it
  transition_to_primary_storage_class = "AFTER_1_ACCESS"

  posix_uid                  = 1000
  posix_gid                  = 1000
  root_directory_path        = "/app/data"
  root_directory_permissions = "0750"

  mount_targets = [
    {
      subnet_id          = "subnet-0abc123456def7890"
      security_group_ids = ["sg-0abc123456def7890"]
    },
    {
      subnet_id          = "subnet-0def456789abc1234"
      security_group_ids = ["sg-0abc123456def7890"]
    },
    {
      subnet_id          = "subnet-0ghi789012jkl3456"
      security_group_ids = ["sg-0abc123456def7890"]
    }
  ]

  file_system_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceEncryptedTransport"
        Effect = "Deny"
        Principal = { AWS = "*" }
        Action    = "*"
        Resource  = "*"
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })

  replication_destination = {
    region     = "eu-west-1"
    kms_key_id = "arn:aws:kms:eu-west-1:123456789012:key/mrk-xyz789"
  }

}
```

---

## Outputs

| Name | Description |
|------|-------------|
| `id` | EFS file system ID |
| `arn` | EFS file system ARN |
| `dns_name` | EFS file system DNS name |
| `access_point_id` | EFS access point ID |
| `access_point_arn` | EFS access point ARN |
| `mount_target_ids` | List of mount target IDs |
| `file_system_policy_id` | File system ID the policy is attached to (null if not configured) |
| `replication_configuration_id` | Source file system ID of replication (null if not configured) |
