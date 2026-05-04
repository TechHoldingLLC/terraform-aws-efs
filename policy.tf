##############################
# EFS File System Policy   ##
##############################

resource "aws_efs_file_system_policy" "file_system_policy" {
  count = var.file_system_policy != null ? 1 : 0

  file_system_id                     = aws_efs_file_system.file_system.id
  policy                             = var.file_system_policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check # For safety purpose should be this is set to false by default, but can be set to true to bypass the safety check that prevents locking yourself out of the file system when applying a policy that denies all actions. Use with caution.
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
