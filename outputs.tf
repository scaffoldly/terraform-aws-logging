output "bucket_name" {
  value       = aws_s3_bucket.logs.id
  description = "The logs bucket name"
}
