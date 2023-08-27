data "aws_cloudfront_cache_policy" "cf_policy_info" {
  name = var.cf_caching_policy_name
}