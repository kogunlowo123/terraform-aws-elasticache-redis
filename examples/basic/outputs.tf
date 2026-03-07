output "primary_endpoint" {
  description = "Primary endpoint address of the Redis cluster."
  value       = module.redis.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint address of the Redis cluster."
  value       = module.redis.reader_endpoint_address
}
