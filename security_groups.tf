resource "aws_security_group" "this" {
  for_each = {
    for scg in var.security_groups :
    scg.identifier => scg
  }

  vpc_id      = var.vpc_id
  description = each.value.description
  name_prefix = join("-", ["scg", local.common_name_tag, each.value.name_tag_postfix])

  tags = merge(
    var.default_tags,
    each.value.additional_tag,
    {
      "Name" = join("-", ["scg", local.common_name_tag, each.value.name_tag_postfix])
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ingress, egress]
  }
}
