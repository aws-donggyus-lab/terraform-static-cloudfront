##########################################################################################
### Common
##########################################################################################
variable "common_name" {}
variable "env" {
  default = "common"
}

##########################################################################################
### S3
##########################################################################################
variable "s3_is_versioning" {
  description = "s3 versioning 여부"
  type        = bool
  default     = true
}

variable "s3_acl" {
  description = "버킷의 액세스 관리 여부"
  type        = string
  default     = "private"

  validation {
    condition = contains(["private", "public-read", "public-read-write",
      "aws-exec-read",
    "authenticated-read", "log-delivery-write", "private"], var.s3_acl)
    error_message = "s3 acl list must be belons to => private, public-read, public-read-write, aws-exec-read, authenticated-read, log-delivery-write, private"
  }
}

variable "s3_cors_rule" {
  default = {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

variable "s3_source" {}

##########################################################################################
### CloudFront
##########################################################################################
variable "cf_acm" {
  default = null
}

variable "cf_enabled" {
  default = true
}
variable "cf_is_ipv6" {
  default = false
}
variable "cf_comment" {
  default = ""
}

variable "cf_default_object" {
  default = "index.html"
}
variable "cf_alias" {
  type    = list(string)
  default = []
}
variable "cf_waf_id" {
  description = "방화벽"
  default     = null
}

## cf origin
variable "cf_origin_attempts" {
  default = 3
}
variable "cf_origin_timeout" {
  default = 10
}

## cf cache
variable "cf_caching_policy_name" {
  description = "data 타입으로 가져올 예정"
  type        = string
}

variable "cf_caching_allow_methods" {
  description = "허용하는 http 메서드"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.cf_caching_allow_methods :
      contains(["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"], v)
    ])

    error_message = "must be belong to DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT"
  }
}

variable "cf_caching_cache_methods" {
  description = "캐시되는 http 메서드"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.cf_caching_cache_methods :
      contains(["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"], v)
    ])

    error_message = "must be belong to DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT"
  }
}

variable "cf_caching_viewer_policy" {
  description = "액세스 정책"
  type        = string
  default     = "allow-all"

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.cf_caching_viewer_policy)
    error_message = "must be belong to => allow_all, https-only, redirec-to-https"
  }
}

variable "cf_caching_ttl" {
  type = object({
    default_ttl = number
    min_ttl     = number
    max_ttl     = number
  })
}

## cf restriction
variable "cf_geo_restriction_type" {
  description = "지리적 제한"
  type        = string

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cf_geo_restriction_type)
    error_message = "must be belong to => none, whiltelist, blacklist"
  }
}

variable "cf_geo_restriction_locations" {
  type    = list(string)
  default = null
}

## cf viewer certificate
variable "cf_viewer_acm_arn" {
  default = null
}
variable "cf_minimum_protocol_version" {
  default = null
}
variable "cf_ssl_support_method" {
  default = null
}