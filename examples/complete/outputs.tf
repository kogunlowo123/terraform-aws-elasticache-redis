output "replication_group_id" {
  description = "ID of the Redis replication group."
  value       = module.redis.replication_group_id
}

output "replication_group_arn" {
  description = "ARN of the Redis replication group."
  value       = module.redis.replication_group_arn
}

output "configuration_endpoint" {
  description = "Configuration endpoint address for cluster mode."
  value       = module.redis.configuration_endpoint_address
}

output "primary_endpoint" {
  description = "Primary endpoint address."
  value       = module.redis.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint address."
  value       = module.redis.reader_endpoint_address
}

output "security_group_id" {
  description = "ID of the Redis security group."
  value       = module.redis.security_group_id
}

output "auth_token_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the auth token."
  value       = module.redis.auth_token_secret_arn
}

output "engine_version" {
  description = "Actual Redis engine version."
  value       = module.redis.engine_version
}
