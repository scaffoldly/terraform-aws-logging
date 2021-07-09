[![Maintained by Scaffoldly](https://img.shields.io/badge/maintained%20by-scaffoldly-blueviolet)](https://github.com/scaffoldly)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/scaffoldly/terraform-aws-logging)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.15.0-blue.svg)

## Description

Configure secure logging for an AWS Account + KMS Encryption

- CloudTrail Bucket + Access + Configuration
- CloudFront Bucket + Access

## Usage

```hcl
module "aws_logging" {
  source  = "scaffoldly/logging/aws"
  account_name = module.aws_organization.account_name
}
```

## Roadmap

- Deprecate this module
- Split into multiple modules
  - Logging into root account
  - CloudTrail Logging into terraform-aws-organization
  - CloudFront Logging into public websites

<!-- BEGIN_TF_DOCS -->

## Requirements

## Providers

## Modules

## Resources

## Inputs

## Outputs

<!-- END_TF_DOCS -->
