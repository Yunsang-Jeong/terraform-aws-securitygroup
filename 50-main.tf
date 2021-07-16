########################################
# Create empty security groups
resource "aws_security_group" "this" {
  for_each = { for scg in var.security_groups : scg.identifier => scg }

  vpc_id      = var.vpc_id
  description = each.value.description
  name        = join("-", compact(["scg", local.name_tag_middle, each.value.name_tag_postfix]))
  tags = merge(
    var.global_additional_tag,
    each.value.additional_tag,
    {
      "Name" = join("-", compact(["scg", local.name_tag_middle, each.value.name_tag_postfix]))
    }
  )

  lifecycle {
    create_before_destroy = true
    # ignore_changes = [ingress, egress]
  }
}
########################################


########################################
# Re-format rules in security groups
locals {
  hash = flatten([
    for scg in var.security_groups : [
      for ingress in scg.ingresses : [
        md5(join("_", [
          scg.identifier,
          ingress.protocol,
          ingress.from_port,
          ingress.to_port,
          ingress.description,
          ingress.cidr_blocks == null ? "null" : join("-", ingress.cidr_blocks),
          ingress.ipv6_cidr_blocks == null ? "null" : join("-", ingress.ipv6_cidr_blocks),
          ingress.prefix_list_ids == null ? "null" : join("-", ingress.prefix_list_ids),
          ingress.source_security_group_id == null ? "null" : ingress.source_security_group_id,
          ingress.self == null ? "null" : ingress.self
        ]))
      ]
    ]
  ])
  rules = flatten([
    for scg in var.security_groups : [
      for ingress in scg.ingresses : {
        security_group_id        = lookup(aws_security_group.this, scg.identifier).id
        description              = ingress.description
        from_port                = ingress.from_port
        to_port                  = ingress.to_port
        protocol                 = ingress.protocol
        cidr_blocks              = ingress.cidr_blocks == [] ? null : ingress.cidr_blocks
        ipv6_cidr_blocks         = ingress.ipv6_cidr_blocks == [] ? null : ingress.ipv6_cidr_blocks
        prefix_list_ids          = ingress.prefix_list_ids == [] ? null : ingress.prefix_list_ids
        source_security_group_id = ingress.source_security_group_id != null ? ingress.source_security_group_id : (ingress.source_security_group_identifier != null ? lookup(aws_security_group.this, ingress.source_security_group_identifier).id : null)
        self                     = ingress.self == false ? null : ingress.self
      }
    ]
  ])
}
########################################


########################################
# Create rules and assgin it to security groups
resource "aws_security_group_rule" "ingress" {
  for_each = zipmap(local.hash, local.rules)

  type                     = "ingress"
  security_group_id        = each.value.security_group_id
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks         = each.value.ipv6_cidr_blocks
  prefix_list_ids          = each.value.prefix_list_ids
  source_security_group_id = each.value.source_security_group_id
  self                     = each.value.self

  depends_on = [aws_security_group.this]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress" {
  for_each = { for scg in var.security_groups : scg.identifier => scg }

  type                     = "egress"
  security_group_id        = lookup(aws_security_group.this, each.value.identifier).id
  description              = "Default"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = []
  prefix_list_ids          = []
  source_security_group_id = null
  self                     = null

  depends_on = [aws_security_group.this]

  lifecycle {
    create_before_destroy = true
  }
}
########################################