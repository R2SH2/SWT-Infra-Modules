---
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Feature Description

<!-- A clear and concise description of the feature you'd like to see -->

## Affected Module

<!-- Which module would this feature enhance? -->

- [ ] vpc-networking
- [ ] s3-cloudfront
- [ ] ec2-backend
- [ ] rds-postgresql
- [ ] New module
- [ ] Repository-wide
- [ ] Other (specify):

## Problem Statement

<!-- What problem does this feature solve? -->
<!-- Is your feature request related to a problem? -->

**Current Situation**:


**Desired Situation**:


## Proposed Solution

<!-- Describe the solution you'd like -->

### Example Configuration

```hcl
# How would you like to use this feature?
module "example" {
  source = "..."

  # New feature configuration
  new_feature_enabled = true
  new_feature_config = {
    # ...
  }
}
```

### Expected Outputs

```hcl
# What outputs would this feature provide?
output "new_feature_output" {
  value = module.example.new_feature_result
}
```

## Alternatives Considered

<!-- Describe alternatives you've considered -->

-
-

## Use Cases

<!-- Describe specific use cases for this feature -->

1. **Use Case 1**: ...
2. **Use Case 2**: ...
3. **Use Case 3**: ...

## Benefits

<!-- What are the benefits of implementing this feature? -->

- **Performance**: ...
- **Cost**: ...
- **Security**: ...
- **Usability**: ...
- **Other**: ...

## Cost Impact

<!-- Will this feature impact AWS costs? -->

**Estimated Monthly Cost**: $XXX

**Cost Justification**:


## Security Implications

<!-- Are there any security considerations? -->

- [ ] No security impact
- [ ] Improves security
- [ ] Requires security review
- [ ] Changes IAM permissions
- [ ] Modifies network security

**Details**:


## Implementation Complexity

<!-- How complex would this be to implement? -->

- [ ] Low - Simple configuration change
- [ ] Medium - Requires new resources
- [ ] High - Significant architectural change

## Breaking Changes

<!-- Would this introduce breaking changes? -->

- [ ] No breaking changes
- [ ] Minor breaking changes (can be mitigated)
- [ ] Major breaking changes (requires new major version)

**Details**:


## Additional Context

<!-- Add any other context, screenshots, or examples -->

## Related Issues

<!-- Link to related issues or PRs -->

- Related to #
- Depends on #
- Blocks #

## Checklist

- [ ] I have searched existing issues/PRs to ensure this isn't a duplicate
- [ ] I have clearly described the use case
- [ ] I have considered alternatives
- [ ] I have thought about backward compatibility
- [ ] I understand this may take time to implement
- [ ] I am willing to contribute (optional)

## Willingness to Contribute

<!-- Would you be willing to help implement this feature? -->

- [ ] Yes, I can submit a PR
- [ ] Yes, I can help with testing
- [ ] Yes, I can help with documentation
- [ ] No, but I can provide feedback
- [ ] No, I just want to suggest the idea
