# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: security@yourcompany.com

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information:

- Type of issue (e.g., privilege escalation, credential exposure, etc.)
- Full paths of source file(s) related to the issue
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## Security Best Practices

When using these modules, follow these security best practices:

### 1. Credentials Management
- ✅ Never commit credentials to Git
- ✅ Use AWS Secrets Manager or Parameter Store
- ✅ Use IAM roles instead of access keys
- ✅ Enable MFA for privileged accounts

### 2. Network Security
- ✅ Use private subnets for databases
- ✅ Restrict security group rules to minimum required
- ✅ Avoid `0.0.0.0/0` for SSH access
- ✅ Use VPC endpoints to avoid internet traffic

### 3. Encryption
- ✅ Enable encryption at rest (enabled by default in our modules)
- ✅ Use TLS/SSL for data in transit
- ✅ Manage KMS keys appropriately
- ✅ Rotate credentials regularly

### 4. Access Control
- ✅ Follow principle of least privilege
- ✅ Use IAM policies to restrict access
- ✅ Enable CloudTrail for audit logging
- ✅ Review and update IAM policies regularly

### 5. Monitoring & Logging
- ✅ Enable CloudWatch logging
- ✅ Set up security alerts
- ✅ Monitor for unusual activity
- ✅ Enable VPC Flow Logs

### 6. Terraform State Security
- ✅ Use remote state with encryption
- ✅ Enable state locking
- ✅ Restrict access to state files
- ✅ Never commit `.tfstate` files

## Security Scanning

All modules are automatically scanned with:

- **tfsec** - Security scanner for Terraform
- **Checkov** - Static code analysis for infrastructure
- **Trivy** - Vulnerability scanner

Run security scans locally:

```bash
# Install tfsec
brew install tfsec

# Run scan
tfsec modules/

# Run with custom checks
tfsec modules/ --minimum-severity MEDIUM
```

## Known Security Considerations

### EC2 Module
- SSH access is enabled by default. Restrict `ssh_cidr_blocks` to your IP
- IMDSv2 is enforced by default for enhanced security
- Consider using AWS Systems Manager Session Manager instead of SSH

### RDS Module
- Database is placed in private subnets by default
- Passwords are auto-generated and stored in Secrets Manager
- Single-AZ deployments have no failover capability
- Enable deletion protection for production databases

### S3 Module
- Bucket is private with public access blocked
- CloudFront uses Origin Access Identity (OAI)
- Consider using CloudFront signed URLs for sensitive content

### VPC Module
- NAT Gateway is disabled by default for cost savings
- Resources in private subnets without NAT Gateway cannot reach internet
- Consider VPC endpoints for AWS service access

## Vulnerability Disclosure Process

1. **Report received** - We acknowledge receipt within 48 hours
2. **Assessment** - We assess severity and impact (3-5 business days)
3. **Fix development** - We develop and test a fix
4. **Release** - We release a patch and security advisory
5. **Disclosure** - We publicly disclose 30 days after patch release

## Security Updates

Subscribe to security updates:
- Watch this repository for security advisories
- Enable GitHub security alerts
- Join our security mailing list: security-updates@yourcompany.com

## Compliance

Our modules are designed with compliance in mind:

- **SOC 2** - Encryption, access control, logging
- **HIPAA** - Encryption, audit trails, access controls
- **PCI DSS** - Network isolation, encryption, logging
- **GDPR** - Data encryption, access controls

However, compliance is a shared responsibility. You must:
- Configure modules appropriately for your compliance needs
- Implement additional controls as required
- Regularly audit your infrastructure
- Maintain compliance documentation

## Security Contacts

- **Security Team**: security@yourcompany.com
- **Platform Engineering**: platform@yourcompany.com
- **Emergency**: +1-XXX-XXX-XXXX (24/7)

---

Last updated: 2025-01-12
