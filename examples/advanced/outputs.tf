output "configuration_endpoint" {
  description = "Configuration endpoint address for cluster mode."
  value       = module.redis_cluster_mode.configuration_endpoint_address
}

output "security_group_id" {
  description = "ID of the Redis security group."
  value       = module.redis_cluster_mode.security_group_id
}

output "auth_token_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the auth token."
  value       = module.redis_cluster_mode.auth_token_secret_arn
}
