#####################
# EFS File System  ##
####################

resource "aws_efs_file_system" "file_system" {
  creation_token         = var.creation_token
  encrypted              = var.encrypted
  kms_key_id             = var.kms_key_id
  performance_mode       = var.performance_mode
  throughput_mode        = var.throughput_mode
  availability_zone_name = var.one_zone_storage ? var.availability_zone : null

  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null

  # IF transaition_to_ia is not set then skip the lifecycle_policy block for it, otherwise it will default to "AFTER_1_DAY" and always transition to IA after 1 day.
  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia != null ? [1] : []
    content {
      transition_to_ia = var.transition_to_ia
    }
  }

  # Skip archive lifecycle policy for One Zone storage or non-elastic throughput mode — both are unsupported.
  dynamic "lifecycle_policy" {
    for_each = (!var.one_zone_storage && var.throughput_mode == "elastic" && var.transition_to_archive != null) ? [1] : []
    content {
      transition_to_archive = var.transition_to_archive
    }
  }

  # Skip primary storage class transition lifecycle policy if not set, otherwise it will default to "AFTER_1_DAY" and always transition to primary storage after 1 day.
  dynamic "lifecycle_policy" {
    for_each = var.transition_to_primary_storage_class != null ? [1] : []
    content {
      transition_to_primary_storage_class = var.transition_to_primary_storage_class
    }
  }
}

#######################
# EFS Backup Policy  ##
#######################

resource "aws_efs_backup_policy" "backup_policy" {
  file_system_id = aws_efs_file_system.file_system.id

  backup_policy {
    status = var.enable_backup ? "ENABLED" : "DISABLED"
  }
}

######################
# EFS Mount Target  ##
######################

resource "aws_efs_mount_target" "mount_target" {
  for_each = { for mt in var.mount_targets : mt.subnet_id => mt }

  file_system_id  = aws_efs_file_system.file_system.id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_group_ids
}

##############################
# EFS File System Policy   ##
##############################

resource "aws_efs_file_system_policy" "file_system_policy" {
  count = var.file_system_policy != null ? 1 : 0

  file_system_id                     = aws_efs_file_system.file_system.id
  policy                             = var.file_system_policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check # For safety perpose this is set to false by default, but can be set to true to bypass the safety check that prevents locking yourself out of the file system when applying a policy that denies all actions. Use with caution.
}

#################################
# EFS Replication Configuration ##
#################################

resource "aws_efs_replication_configuration" "replication" {
  count = var.replication_destination != null ? 1 : 0

  # Existing file system ID is used as the source for replication.
  source_file_system_id = aws_efs_file_system.file_system.id

  destination {
    availability_zone_name = var.replication_destination.availability_zone_name # Not required if replicating to a different region
    kms_key_id             = var.replication_destination.kms_key_id             # Optional, but recommended for cross-region replication. if omitted, the replication will use the default EFS KMS key in the destination region.
    region                 = var.replication_destination.region                 # Not required if replicating within the same region
    file_system_id         = var.replication_destination.file_system_id
  }
}

######################
# EFS Access Point  ##
######################

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.file_system.id

  posix_user {
    uid = var.posix_uid
    gid = var.posix_gid
  }

  root_directory {
    path = var.root_directory_path
    creation_info {
      owner_uid   = var.posix_uid
      owner_gid   = var.posix_gid
      permissions = var.root_directory_permissions
    }
  }
}
