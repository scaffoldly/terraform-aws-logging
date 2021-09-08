locals {
  bucket_prefix = "${var.organization}-logs"
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "logs" {
  bucket_prefix = local.bucket_prefix
  acl           = "log-delivery-write"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.logs.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = ["bucket-owner-full-control"]
    }

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "delivery.logs.amazonaws.com",
      ]
    }
  }

  statement {
    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.logs.id}",
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "delivery.logs.amazonaws.com",
      ]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [
    aws_s3_bucket_public_access_block.logs,
  ]
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "cloudtrail"
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  s3_bucket_name = aws_s3_bucket.logs.id

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:${data.aws_partition.current.partition}:s3:::"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:${data.aws_partition.current.partition}:lambda"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::DynamoDB::Table"
      values = ["arn:${data.aws_partition.current.partition}:dynamodb"]
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  depends_on = [
    aws_s3_bucket_policy.bucket_policy,
  ]
}
