################################################################################
# Auth Token
################################################################################

resource "random_password" "auth_token" {
  count = var.auth_token_enabled ? 1 : 0

  length           = 64
  special          = true
  override_special = "!&#$^<>-"
}

resource "aws_secretsmanager_secret" "auth_token" {
  count = var.auth_token_enabled ? 1 : 0

  name        = "${var.name}-redis-auth-token"
  description = "Auth token for ElastiCache Redis replication group ${var.name}"
  kms_key_id  = var.kms_key_arn

  tags = local.default_tags
}

resource "aws_secretsmanager_secret_version" "auth_token" {
  count = var.auth_token_enabled ? 1 : 0

  secret_id     = aws_secretsmanager_secret.auth_token[0].id
  secret_string = random_password.auth_token[0].result
}

################################################################################
# Subnet Group
################################################################################

resource "aws_elasticache_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = local.default_tags
}

################################################################################
# Parameter Group
################################################################################

resource "aws_elasticache_parameter_group" "this" {
  name   = var.name
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = local.all_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  name        = "${var.name}-redis"
  description = "Security group for ElastiCache Redis ${var.name}"
  vpc_id      = var.vpc_id

  tags = local.default_tags
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.this.id
  description              = "Allow Redis access from security group ${var.allowed_security_group_ids[count.index]}"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this.id
  description       = "Allow Redis access from CIDR blocks"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
}

################################################################################
# Replication Group
################################################################################

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.name
  description          = var.description
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.this.name
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.this.id]

  # Cluster configuration
  num_cache_clusters = local.cluster_mode_enabled ? null : var.num_cache_clusters
  num_node_groups    = local.cluster_mode_enabled ? var.num_node_groups : null
  replicas_per_node_group = local.cluster_mode_enabled ? var.replicas_per_node_group : null

  # High availability
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  # Encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  kms_key_id                 = var.kms_key_arn
  auth_token                 = var.auth_token_enabled ? random_password.auth_token[0].result : null

  # Backup
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Notifications
  notification_topic_arn = var.notification_topic_arn

  # Log delivery
  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configurations

    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = local.default_tags
}

################################################################################
# CloudWatch Alarms
################################################################################

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.name}-redis-cpu-utilization"
  alarm_description   = "Redis cluster ${var.name} CPU utilization above 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.this.id
  }

  alarm_actions = var.notification_topic_arn != null ? [var.notification_topic_arn] : []
  ok_actions    = var.notification_topic_arn != null ? [var.notification_topic_arn] : []

  tags = local.default_tags
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "${var.name}-redis-database-memory-usage"
  alarm_description   = "Redis cluster ${var.name} database memory usage above 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.this.id
  }

  alarm_actions = var.notification_topic_arn != null ? [var.notification_topic_arn] : []
  ok_actions    = var.notification_topic_arn != null ? [var.notification_topic_arn] : []

  tags = local.default_tags
}

resource "aws_cloudwatch_metric_alarm" "evictions" {
  alarm_name          = "${var.name}-redis-evictions"
  alarm_description   = "Redis cluster ${var.name} evictions detected"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.this.id
  }

  alarm_actions = var.notification_topic_arn != null ? [var.notification_topic_arn] : []
  ok_actions    = var.notification_topic_arn != null ? [var.notification_topic_arn] : []

  tags = local.default_tags
}

resource "aws_cloudwatch_metric_alarm" "connections" {
  alarm_name          = "${var.name}-redis-current-connections"
  alarm_description   = "Redis cluster ${var.name} current connections above 50000"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 50000
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.this.id
  }

  alarm_actions = var.notification_topic_arn != null ? [var.notification_topic_arn] : []
  ok_actions    = var.notification_topic_arn != null ? [var.notification_topic_arn] : []

  tags = local.default_tags
}
