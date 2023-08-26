##########################################################################################
### S3
##########################################################################################
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.common_name}-static-site"
  acl    = "private" // public으로 하면 보안상 위험

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_headers = lookup(var.s3_cors_rule, "allowed_headers")
    allowed_methods = lookup(var.s3_cors_rule, "allowed_methods")
    allowed_origins = lookup(var.s3_cors_rule, "allowed_origins")
    expose_headers  = lookup(var.s3_cors_rule, "expose_headers")
    max_age_seconds = lookup(var.s3_cors_rule, "max_age_seconds")
  }

  tags = {
    Name     = "${var.common_name}"
    Resource = "s3"
    Env      = "${var.env}"
  }
}

// Default S3 Object (index.html)
resource "aws_s3_bucket_object" "s3_object" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  key    = "${var.env}/index.html"
  source = var.s3_source

  lifecycle {
    ignore_changes = [
      source
    ]
  }
}

##########################################################################################
### CloudFront
##########################################################################################
resource "aws_cloudfront_origin_access_control" "cf_origin_access_control" {
  name                              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  enabled             = var.cf_enabled
  is_ipv6_enabled     = var.cf_is_ipv6
  aliases             = var.cf_alias
  comment             = var.cf_comment
  default_root_object = var.cf_default_object
  web_acl_id          = var.cf_waf_id

  origin {
    origin_access_control_id = aws_cloudfront_origin_access_control.cf_origin_access_control.id
    connection_attempts      = var.cf_origin_attempts
    connection_timeout       = var.cf_origin_timeout
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_path              = "/${var.env}"
  }

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.cf_policy_info.id
    allowed_methods  = var.cf_caching_allow_methods
    cached_methods   = var.cf_caching_cache_methods
    target_origin_id = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    compress         = true

    viewer_protocol_policy = var.cf_caching_viewer_policy
    default_ttl            = lookup(var.cf_caching_ttl, "default_ttl")
    min_ttl                = lookup(var.cf_caching_ttl, "min_ttl")
    max_ttl                = lookup(var.cf_caching_ttl, "max_ttl")
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cf_geo_restriction_type
      locations        = var.cf_geo_restriction_locations
    }
  }

  // acm을 사용할 경우
  dynamic "viewer_certificate" {
    for_each = var.cf_viewer_acm_arn == null ? [] : [1]
    content {
      acm_certificate_arn      = var.cf_viewer_acm_arn
      minimum_protocol_version = var.cf_minimum_protocol_version
      ssl_support_method       = var.cf_ssl_support_method
    }
  }

  // acm을 사용하지 않고 cloud-front의 Default 설정을 할 경우
  dynamic "viewer_certificate" {
    for_each = var.cf_viewer_acm_arn == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }
}


##########################################################################################
### CloudFront +S3 + Policy
##########################################################################################
# resource "aws_s3_bucket_policy" "s3_bucket_policy" {

# }

output "v" {
  value = aws_s3_bucket.s3_bucket
}