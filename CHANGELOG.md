# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added

- Initial release of the terraform-aws-elasticache-redis module
- ElastiCache Redis replication group with configurable cluster mode
- Custom parameter group with user-defined parameters
- Subnet group for VPC placement
- Security group with configurable ingress rules (security groups and CIDR blocks)
- Encryption at rest with optional KMS key
- Encryption in transit
- AUTH token generation and storage in AWS Secrets Manager
- Automatic failover and Multi-AZ support
- Configurable backup retention and maintenance windows
- SNS notification support
- Log delivery configuration (CloudWatch Logs / Kinesis Data Firehose)
- CloudWatch metric alarms for CPU, memory, evictions, and connections
- Basic, advanced, and complete usage examples
