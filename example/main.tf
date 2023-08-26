provider "aws" {
  region = "ap-northeast-2"
}

module "static-site" {
  source = "../"

  common_name = "dk-example"
  env         = "common"

  s3_is_versioning = true
  s3_acl           = "private" // 변경은 자제...
  s3_cors_rule = {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

output "value" {
  value = module.static-site
}