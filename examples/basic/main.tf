provider "aws" {
  region = "us-east-1"
}

module "redis" {
  source = "../../"

  name        = "my-redis-basic"
  description = "Basic Redis cluster"

  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

  node_type          = "cache.t3.micro"
  num_cache_clusters = 2

  # Disable features for simplicity
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token_enabled         = false
  automatic_failover_enabled = true
  multi_az_enabled           = false

  tags = {
    Environment = "dev"
  }
}
