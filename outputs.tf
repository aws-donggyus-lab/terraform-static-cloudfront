output "s3" {
  value = aws_s3_bucket.s3_bucket
}

output "cloudfront" {
  value = aws_cloudfront_distribution.s3_distribution
}