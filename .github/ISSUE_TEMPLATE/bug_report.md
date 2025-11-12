---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

<!-- A clear and concise description of what the bug is -->

## Affected Module

<!-- Which module is affected? -->

- [ ] vpc-networking
- [ ] s3-cloudfront
- [ ] ec2-backend
- [ ] rds-postgresql
- [ ] Other (specify):

## To Reproduce

Steps to reproduce the behavior:

1. Use module configuration: '...'
2. Run terraform command: '...'
3. See error: '...'

## Expected Behavior

<!-- A clear description of what you expected to happen -->

## Actual Behavior

<!-- What actually happened -->

## Module Configuration

```hcl
# Paste your module configuration here
module "example" {
  source = "..."
  # ...
}
```

## Terraform Output

```
# Paste relevant terraform output here
```

## Environment

- **Module Version**: [e.g., v1.0.0]
- **Terraform Version**: [e.g., 1.6.0]
- **AWS Provider Version**: [e.g., 5.0.0]
- **Operating System**: [e.g., macOS 13.0]
- **AWS Region**: [e.g., us-east-1]

## Additional Context

<!-- Add any other context about the problem here -->
<!-- Screenshots, logs, or related issues -->

## Possible Solution

<!-- If you have suggestions on how to fix the bug -->

## Checklist

- [ ] I have searched existing issues to ensure this isn't a duplicate
- [ ] I have provided all required information
- [ ] I have tested with the latest version of the module
- [ ] I have included relevant logs and error messages
