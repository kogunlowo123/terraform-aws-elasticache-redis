terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  name               = "test-redis"
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  node_type          = "cache.t3.medium"
  engine_version     = "7.1"
  num_cache_clusters = 2

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  automatic_failover_enabled = true
  multi_az_enabled           = true

  tags = {
    Environment = "test"
    Module      = "terraform-aws-elasticache-redis"
  }
}
