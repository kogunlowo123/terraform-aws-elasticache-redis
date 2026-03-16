variable "name" {
  description = "Name for the ElastiCache Redis replication group and associated resources."
  type        = string
}

variable "description" {
  description = "Description for the ElastiCache Redis replication group."
  type        = string
  default     = "Managed by Terraform"
}

variable "engine_version" {
  description = "Version number of the Redis engine to use."
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "Instance class for the ElastiCache Redis nodes."
  type        = string
  default     = "cache.t3.medium"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (primary and replicas); ignored when cluster mode is enabled."
  type        = number
  default     = 2
}

variable "num_node_groups" {
  description = "Number of node groups (shards) for cluster mode; set to 0 to disable."
  type        = number
  default     = 0
}

variable "replicas_per_node_group" {
  description = "Number of replica nodes in each node group when cluster mode is enabled."
  type        = number
  default     = 1
}

variable "parameter_group_family" {
  description = "The family of the ElastiCache parameter group (e.g. redis7)."
  type        = string
  default     = "redis7"
}

variable "custom_parameters" {
  description = "Map of custom parameters to apply to the parameter group."
  type        = map(string)
  default     = {}
}

variable "port" {
  description = "Port number on which each cache node will accept connections."
  type        = number
  default     = 6379
}

variable "vpc_id" {
  description = "VPC ID where the ElastiCache cluster and security group will be created."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ElastiCache subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access the Redis cluster."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Redis cluster."
  type        = list(string)
  default     = []
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest."
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit."
  type        = bool
  default     = true
}

variable "auth_token_enabled" {
  description = "Whether to enable AUTH token (password) for Redis."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption at rest; uses default AWS managed key if null."
  type        = string
  default     = null
}

variable "automatic_failover_enabled" {
  description = "Whether to enable automatic failover for the replication group."
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Whether to enable Multi-AZ support for the replication group."
  type        = bool
  default     = true
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots; set to 0 to disable."
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Daily time range for automated backups (e.g. 03:00-05:00 UTC)."
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance (e.g. sun:05:00-sun:07:00 UTC)."
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "notification_topic_arn" {
  description = "ARN of an SNS topic to send ElastiCache notifications to."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Whether changes should be applied immediately or during maintenance."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Whether minor engine upgrades are applied automatically during maintenance."
  type        = bool
  default     = true
}

variable "log_delivery_configurations" {
  description = "List of log delivery configurations for the replication group."
  type = list(object({
    destination      = string
    destination_type = string
    log_format       = string
    log_type         = string
  }))
  default = []
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
