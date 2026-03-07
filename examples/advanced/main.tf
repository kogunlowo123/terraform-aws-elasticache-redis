provider "aws" {
  region = "us-east-1"
}

module "redis_cluster_mode" {
  source = "../../"

  name        = "my-redis-cluster"
  description = "Redis cluster with cluster mode enabled"

  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  node_type               = "cache.r6g.large"
  num_node_groups         = 3
  replicas_per_node_group = 2

  engine_version         = "7.1"
  parameter_group_family = "redis7"

  custom_parameters = {
    "maxmemory-policy" = "allkeys-lru"
  }

  allowed_security_group_ids = ["sg-0123456789abcdef0"]
  allowed_cidr_blocks        = ["10.0.0.0/8"]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token_enabled         = true
  kms_key_arn                = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  automatic_failover_enabled = true
  multi_az_enabled           = true

  snapshot_retention_limit = 14
  snapshot_window          = "02:00-04:00"
  maintenance_window       = "sat:04:00-sat:06:00"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
