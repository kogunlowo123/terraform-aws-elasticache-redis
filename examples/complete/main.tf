provider "aws" {
  region = "us-east-1"
}

################################################################################
# Supporting Resources
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "redis-complete-example"
  }
}

resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "redis-complete-private-${count.index}"
  }
}

resource "aws_security_group" "app" {
  name        = "redis-complete-app"
  description = "Application security group"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "redis-complete-app"
  }
}

resource "aws_sns_topic" "redis_alerts" {
  name = "redis-complete-alerts"
}

resource "aws_kms_key" "redis" {
  description             = "KMS key for Redis encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/elasticache/redis-complete/slow-log"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name              = "/elasticache/redis-complete/engine-log"
  retention_in_days = 30
}

################################################################################
# Redis Module
################################################################################

module "redis" {
  source = "../../"

  name        = "redis-complete"
  description = "Complete Redis example with all features"

  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  node_type               = "cache.r6g.large"
  num_node_groups         = 2
  replicas_per_node_group = 2

  engine_version         = "7.1"
  parameter_group_family = "redis7"

  custom_parameters = {
    "maxmemory-policy"     = "volatile-lru"
    "notify-keyspace-events" = "Ex"
    "slowlog-log-slower-than" = "10000"
  }

  allowed_security_group_ids = [aws_security_group.app.id]
  allowed_cidr_blocks        = ["10.0.0.0/16"]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token_enabled         = true
  kms_key_arn                = aws_kms_key.redis.arn

  automatic_failover_enabled = true
  multi_az_enabled           = true

  snapshot_retention_limit = 30
  snapshot_window          = "01:00-03:00"
  maintenance_window       = "sun:03:00-sun:05:00"

  notification_topic_arn = aws_sns_topic.redis_alerts.arn

  log_delivery_configurations = [
    {
      destination      = aws_cloudwatch_log_group.redis_slow_log.name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    },
    {
      destination      = aws_cloudwatch_log_group.redis_engine_log.name
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "engine-log"
    },
  ]

  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "infrastructure"
  }
}
