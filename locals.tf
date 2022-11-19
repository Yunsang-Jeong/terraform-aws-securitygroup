# data.aws_region.this.name
data "aws_region" "this" {}

locals {
  region_alias_map = {
    us-east-1      = "use1"
    ap-northeast-2 = "apne2"
  }

  region       = data.aws_region.this.name
  region_alias = lookup(local.region_alias_map, local.region)
  project_name = var.name_tag_convention.project_name
  stage        = var.name_tag_convention.stage

  common_name_tag = join("-", [local.region_alias, local.project_name, local.stage])
}
