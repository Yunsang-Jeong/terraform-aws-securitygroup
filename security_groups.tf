resource "aws_security_group" "this" {
  for_each = {
    for scg in var.security_groups :
    scg.identifier => scg
  }

  vpc_id      = var.vpc_id
  description = each.value.description
  name_prefix = "${var.name_prefix}-${each.key}"

  tags = merge(
    var.global_additional_tag,
    each.value.additional_tag,
    {
      "Name" = "${var.name_prefix}-${each.key}"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ingress, egress]
  }
}
