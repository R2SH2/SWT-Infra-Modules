# S3 + CloudFront Static Hosting Module

This module creates an S3 bucket with CloudFront distribution for hosting static websites securely and efficiently.

## Features

- S3 bucket with encryption and versioning
- CloudFront distribution with Origin Access Identity (OAI)
- Custom error responses for SPA support
- HTTPS enforcement
- Custom domain support with ACM certificates
- Configurable caching behavior
- Geo-restriction support

## Usage

### Basic Usage

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name = "my-unique-website-bucket"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### With Custom Domain

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name         = "my-unique-website-bucket"
  domain_aliases      = ["www.example.com", "example.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/xxxxx"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### SPA Configuration (React, Vue, Angular)

For Single Page Applications that use client-side routing:

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name = "my-spa-bucket"

  # Route all 404s to index.html for client-side routing
  custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 300
    },
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 300
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Cost-Optimized Configuration

```hcl
module "static_website" {
  source = "./modules/s3-cloudfront"

  bucket_name            = "my-budget-website"
  cloudfront_price_class = "PriceClass_100"  # US, Canada, Europe only
  enable_versioning      = false
  enable_cloudfront_logging = false

  # Aggressive caching for static assets
  default_ttl = 86400  # 24 hours
  max_ttl     = 604800 # 7 days

  tags = {
    Environment = "production"
  }
}
```

## Deployment Process

After creating the infrastructure:

1. Upload your static files to the S3 bucket:
```bash
aws s3 sync ./build s3://your-bucket-name --delete
```

2. Invalidate CloudFront cache (if needed):
```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| bucket_name | Name of the S3 bucket (must be globally unique) | string | - | yes |
| force_destroy | Allow bucket to be destroyed even if it contains objects | bool | false | no |
| enable_versioning | Enable versioning for the S3 bucket | bool | false | no |
| cloudfront_price_class | Price class for CloudFront | string | "PriceClass_100" | no |
| domain_aliases | List of domain aliases (requires ACM cert) | list(string) | [] | no |
| acm_certificate_arn | ARN of ACM certificate (must be in us-east-1) | string | null | no |
| default_root_object | Default root object | string | "index.html" | no |
| viewer_protocol_policy | Viewer protocol policy | string | "redirect-to-https" | no |
| custom_error_responses | Custom error responses | list(object) | See variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_id | The ID of the S3 bucket |
| s3_bucket_arn | The ARN of the S3 bucket |
| cloudfront_distribution_id | The ID of the CloudFront distribution |
| cloudfront_domain_name | The domain name of the CloudFront distribution |
| website_url | The full HTTPS URL of the website |

## Cost Breakdown

### Monthly Estimated Costs

**S3 Storage**:
- First 50 TB: $0.023 per GB
- Example: 1 GB = $0.023/month

**CloudFront**:
- First 10 TB: $0.085 per GB (North America/Europe)
- HTTP/HTTPS requests: $0.0075-0.01 per 10,000 requests
- Example with PriceClass_100: ~$2-5/month for typical traffic

**Total Estimate**: $3-5/month for low-to-medium traffic sites

### Cost Optimization Tips

1. Use `PriceClass_100` for North America/Europe only
2. Set appropriate cache TTLs to reduce origin requests
3. Enable compression in CloudFront
4. Use CloudFront's free tier: 1TB data transfer, 10M HTTP/HTTPS requests per month
5. Disable versioning if not needed

## Security Features

- S3 bucket is private with public access blocked
- CloudFront uses Origin Access Identity (OAI)
- HTTPS enforced by default
- Server-side encryption (AES256)
- Optional geo-restriction

## Notes

- ACM certificates for custom domains must be created in us-east-1 region
- CloudFront distribution deployment takes 15-20 minutes
- Changes to CloudFront distribution can take 10-15 minutes to propagate
