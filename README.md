# terraform-aws-elasticache-redis

Terraform module to provision an Amazon ElastiCache Redis replication group with support for cluster mode, Multi-AZ, AUTH token, encryption at rest and in transit, RBAC, and CloudWatch alarms.

## Features

- **Cluster Mode** - Optional cluster mode with configurable number of shards and replicas per shard
- **High Availability** - Automatic failover and Multi-AZ support
- **Security** - Encryption at rest (with optional KMS key), encryption in transit, and AUTH token stored in AWS Secrets Manager
- **Monitoring** - CloudWatch alarms for CPU utilization, memory usage, evictions, and current connections
- **Logging** - Configurable log delivery to CloudWatch Logs or Kinesis Data Firehose
- **Networking** - Dedicated security group with configurable ingress from security groups and CIDR blocks
- **Customizable** - Custom parameter group with user-defined parameters

## Usage

### Basic

```hcl
module "redis" {
  source = "github.com/kogunlowo123/terraform-aws-elasticache-redis"

  name       = "my-redis"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-abc", "subnet-def"]

  node_type          = "cache.t3.micro"
  num_cache_clusters = 2

  tags = {
    Environment = "dev"
  }
}
```

### Cluster Mode

```hcl
module "redis" {
  source = "github.com/kogunlowo123/terraform-aws-elasticache-redis"

  name       = "my-redis-cluster"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-abc", "subnet-def", "subnet-ghi"]

  node_type               = "cache.r6g.large"
  num_node_groups         = 3
  replicas_per_node_group = 2

  kms_key_arn        = "arn:aws:kms:..."
  auth_token_enabled = true

  tags = {
    Environment = "production"
  }
}
```

## Examples

- [Basic](examples/basic/) - Simple Redis replication group with two nodes
- [Advanced](examples/advanced/) - Cluster mode with encryption and AUTH
- [Complete](examples/complete/) - Full-featured setup with VPC, KMS, SNS, logging, and all options

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| random | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name for the replication group | `string` | n/a | yes |
| description | Description for the replication group | `string` | `"Managed by Terraform"` | no |
| engine_version | Redis engine version | `string` | `"7.1"` | no |
| node_type | Instance class for nodes | `string` | `"cache.t3.medium"` | no |
| num_cache_clusters | Number of cache clusters (non-cluster mode) | `number` | `2` | no |
| num_node_groups | Number of shards (cluster mode) | `number` | `0` | no |
| replicas_per_node_group | Replicas per shard (cluster mode) | `number` | `1` | no |
| parameter_group_family | Parameter group family | `string` | `"redis7"` | no |
| custom_parameters | Custom parameter group parameters | `map(string)` | `{}` | no |
| port | Redis port | `number` | `6379` | no |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnet_ids | Subnet IDs for subnet group | `list(string)` | n/a | yes |
| allowed_security_group_ids | Security groups allowed access | `list(string)` | `[]` | no |
| allowed_cidr_blocks | CIDR blocks allowed access | `list(string)` | `[]` | no |
| at_rest_encryption_enabled | Enable encryption at rest | `bool` | `true` | no |
| transit_encryption_enabled | Enable encryption in transit | `bool` | `true` | no |
| auth_token_enabled | Enable AUTH token | `bool` | `true` | no |
| kms_key_arn | KMS key ARN for encryption | `string` | `null` | no |
| automatic_failover_enabled | Enable automatic failover | `bool` | `true` | no |
| multi_az_enabled | Enable Multi-AZ | `bool` | `true` | no |
| snapshot_retention_limit | Snapshot retention in days | `number` | `7` | no |
| snapshot_window | Backup window | `string` | `"03:00-05:00"` | no |
| maintenance_window | Maintenance window | `string` | `"sun:05:00-sun:07:00"` | no |
| notification_topic_arn | SNS topic ARN for notifications | `string` | `null` | no |
| apply_immediately | Apply changes immediately | `bool` | `false` | no |
| auto_minor_version_upgrade | Auto minor version upgrade | `bool` | `true` | no |
| log_delivery_configurations | Log delivery configurations | `list(object)` | `[]` | no |
| tags | Tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| replication_group_id | ID of the replication group |
| replication_group_arn | ARN of the replication group |
| primary_endpoint_address | Primary endpoint address |
| reader_endpoint_address | Reader endpoint address |
| configuration_endpoint_address | Configuration endpoint (cluster mode) |
| port | Redis port |
| security_group_id | Security group ID |
| security_group_arn | Security group ARN |
| parameter_group_id | Parameter group ID |
| subnet_group_name | Subnet group name |
| auth_token_secret_arn | Secrets Manager secret ARN |
| engine_version | Actual engine version |

## License

MIT License. See [LICENSE](LICENSE) for details.
