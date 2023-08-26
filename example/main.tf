provider "aws" {
  region = "ap-northeast-2"
}

module "static-site" {
    source = "../"

    common_name = "dk-example"
    env = "common"
    
    s3_is_versioning = true
}

output value {
    value = module.static-site
}