################
# outputs.tf  ##
###############

output "access_point_arn" {
  description = "EFS access point ARN"
  value       = aws_efs_access_point.access_point.arn
}

output "access_point_id" {
  description = "EFS access point ID"
  value       = aws_efs_access_point.access_point.id
}

output "arn" {
  description = "EFS file system ARN"
  value       = aws_efs_file_system.file_system.arn
}

output "dns_name" {
  description = "EFS file system DNS name"
  value       = aws_efs_file_system.file_system.dns_name
}

output "file_system_policy_id" {
  description = "EFS file system ID that the policy is attached to (null if no policy configured)"
  value       = length(aws_efs_file_system_policy.file_system_policy) > 0 ? aws_efs_file_system_policy.file_system_policy[0].id : null
}

output "id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.file_system.id
}

output "mount_target_ids" {
  description = "List of EFS mount target IDs"
  value       = values(aws_efs_mount_target.mount_target)[*].id
}

output "replication_configuration_id" {
  description = "Source EFS file system ID of the replication configuration (null if not configured)"
  value       = length(aws_efs_replication_configuration.replication) > 0 ? aws_efs_replication_configuration.replication[0].id : null
}
