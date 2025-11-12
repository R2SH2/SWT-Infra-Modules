## Description

<!-- Provide a brief description of your changes -->

## Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] 🆕 New module
- [ ] ✨ Feature enhancement
- [ ] 🐛 Bug fix
- [ ] 📚 Documentation update
- [ ] 🔧 Configuration change
- [ ] ♻️ Code refactoring
- [ ] 🧪 Test update
- [ ] ⚠️ Breaking change

## Motivation and Context

<!-- Why is this change required? What problem does it solve? -->
<!-- If it fixes an open issue, please link to the issue here. -->

Fixes #(issue)

## Changes Made

<!-- Provide a detailed list of changes -->

-
-
-

## Testing

<!-- Describe the tests you ran to verify your changes -->

### Terraform Commands

```bash
# Commands you ran
terraform fmt -check -recursive
terraform validate
```

### Manual Testing

<!-- Describe any manual testing performed -->

- [ ] Tested in dev environment
- [ ] Tested in staging environment
- [ ] Ran example configurations

## Cost Impact

<!-- Describe any cost implications of this change -->

**Monthly Cost Change**: $XXX

**Breakdown**:
-
-

## Security Considerations

<!-- List any security implications -->

- [ ] No security impact
- [ ] Security review required
- [ ] Credentials handling updated
- [ ] IAM permissions changed
- [ ] Network security modified

**Security Details**:


## Breaking Changes

<!-- List any breaking changes and migration path -->

- [ ] No breaking changes
- [ ] Breaking changes documented below

**Migration Guide**:


## Checklist

<!-- Ensure all items are completed before submitting -->

### Code Quality
- [ ] Code follows the style guidelines (snake_case, proper comments)
- [ ] Terraform fmt passes (`terraform fmt -check -recursive`)
- [ ] Terraform validate passes
- [ ] Linting passes (tflint)
- [ ] No hardcoded credentials or sensitive data

### Documentation
- [ ] Module README.md updated
- [ ] CHANGELOG.md updated
- [ ] Variables have descriptions
- [ ] Outputs have descriptions
- [ ] Examples provided

### Testing
- [ ] Local validation completed
- [ ] Examples tested
- [ ] Security scans passed (tfsec/checkov)
- [ ] No new warnings or errors

### Module Structure
- [ ] versions.tf included with provider requirements
- [ ] variables.tf with proper types and defaults
- [ ] outputs.tf with descriptions
- [ ] examples/ directory with working code
- [ ] Tags support included

## Screenshots / Logs

<!-- If applicable, add screenshots or relevant logs -->

```
Paste relevant logs here
```

## Additional Notes

<!-- Add any additional context about the PR here -->

## Reviewer Notes

<!-- @ mention specific reviewers if needed -->

**Reviewers**: @username

**Special Instructions**:


---

**By submitting this pull request, I confirm that my contribution is made under the terms of the MIT License.**
