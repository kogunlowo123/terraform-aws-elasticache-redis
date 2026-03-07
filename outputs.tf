output "replication_group_id" {
  description = "ID of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.this.id
}

output "replication_group_arn" {
  description = "ARN of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.this.arn
}

output "primary_endpoint_address" {
  description = "Address of the endpoint for the primary node in the replication group."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Address of the endpoint for the reader node in the replication group."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "configuration_endpoint_address" {
  description = "Address of the configuration endpoint for the replication group (cluster mode only)."
  value       = local.cluster_mode_enabled ? aws_elasticache_replication_group.this.configuration_endpoint_address : null
}

output "port" {
  description = "Port number the Redis cluster accepts connections on."
  value       = var.port
}

output "security_group_id" {
  description = "ID of the security group created for the Redis cluster."
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "ARN of the security group created for the Redis cluster."
  value       = aws_security_group.this.arn
}

output "parameter_group_id" {
  description = "ID of the ElastiCache parameter group."
  value       = aws_elasticache_parameter_group.this.id
}

output "subnet_group_name" {
  description = "Name of the ElastiCache subnet group."
  value       = aws_elasticache_subnet_group.this.name
}

output "auth_token_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the Redis auth token."
  value       = var.auth_token_enabled ? aws_secretsmanager_secret.auth_token[0].arn : null
}

output "engine_version" {
  description = "Redis engine version."
  value       = aws_elasticache_replication_group.this.engine_version_actual
}
