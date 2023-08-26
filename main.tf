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
  source = "./files/index.html"

  lifecycle {
    ignore_changes = [
      source
    ]
  }
}

##########################################################################################
### CloudFront
##########################################################################################



##########################################################################################
### CloudFront +S3 + Policy
##########################################################################################

output "v" {
  value = aws_s3_bucket.s3_bucket
}