# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of cost-optimized AWS infrastructure modules

## [1.0.0] - 2025-01-12

### Added
- **vpc-networking** module for VPC with public/private subnets
  - Multi-AZ support
  - Optional NAT Gateway
  - Configurable CIDR blocks
  - Internet Gateway included
- **s3-cloudfront** module for static website hosting
  - S3 bucket with encryption
  - CloudFront distribution with OAI
  - Custom domain support
  - SPA routing support
- **ec2-backend** module for application hosting
  - t3.micro instance configuration
  - Security group management
  - IAM role with SSM access
  - User data support for Docker/Redis
  - Optional Elastic IP
  - CloudWatch monitoring
- **rds-postgresql** module for managed databases
  - db.t4g.micro instance support
  - Automated password generation
  - Secrets Manager integration
  - Automated backups
  - Single-AZ and Multi-AZ options
  - Security group management

### Documentation
- Comprehensive README for each module
- Architecture diagrams
- Cost breakdowns
- Usage examples
- Complete deployment guide

### Infrastructure
- Terraform 1.0+ support
- AWS Provider 5.0+ compatibility
- Version constraints in all modules

---

## Version Guidelines

### Module Versioning

When consuming these modules, always pin to a specific version:

```hcl
module "vpc" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=v1.0.0"
  # ... configuration
}
```

### Breaking Changes

Major version bumps (e.g., 1.x.x → 2.0.0) indicate breaking changes:
- Required variable changes
- Output format changes
- Resource replacements
- Provider version updates

### Non-Breaking Changes

Minor version bumps (e.g., 1.0.x → 1.1.0) indicate new features:
- New optional variables
- New outputs
- New optional resources

Patch version bumps (e.g., 1.0.0 → 1.0.1) indicate bug fixes:
- Documentation updates
- Bug fixes
- Security patches

---

## Migration Guides

### Upgrading from Pre-release to 1.0.0

This is the first stable release. No migration needed.

---

## Links

- [Repository](https://github.com/YOUR_ORG/terraform-modules)
- [Issues](https://github.com/YOUR_ORG/terraform-modules/issues)
- [Pull Requests](https://github.com/YOUR_ORG/terraform-modules/pulls)
