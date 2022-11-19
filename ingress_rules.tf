#
# There is a caution when using 'cidr_blocks', 'ipv6_cidr_blocks', and 'prefix_list_ids' in 'aws_security_group_rule'.
#
# If there is a change in 'cidr_blocks', 
# the 'aws_security_group_rule' itself is replaced(delete and create), not just the changed part.
# 
# This can cause an issue in service operation.
# Therefore, 'aws_security_group_rule' is created by separating the items of 'cidr_block' individually.
#
# (This is the same for 'ipv6_cidr_blocks' and 'prefix_list_ids'.)
#

resource "aws_security_group_rule" "ingress" {
  for_each = merge([
    for scg in var.security_groups : {
      for ingress in scg.ingresses :
      "${scg.identifier}!${ingress.identifier}" => merge(
        ingress,
        {
          security_group_id = lookup(aws_security_group.this, scg.identifier).id
          source_security_group_id = try(
            lookup(aws_security_group.this, ingress.source_security_group_identifier).id,
            ingress.source_security_group_id
          )
        },
      )
      if ingress.cidr_blocks == null && ingress.ipv6_cidr_blocks == null && ingress.prefix_list_ids == null
    }
  ]...)

  type                     = "ingress"
  security_group_id        = each.value.security_group_id
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  self                     = each.value.self

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  for_each = merge(flatten([
    for scg in var.security_groups : [
      for ingress in scg.ingresses : [
        for cidr_block in ingress.cidr_blocks : {
          "${scg.identifier}!${ingress.identifier}!${cidr_block}" = merge(
            ingress,
            {
              security_group_id = lookup(aws_security_group.this, scg.identifier).id
              cidr_blocks       = [cidr_block]
            },
          )
        }
      ]
      if ingress.cidr_blocks != null
    ]
  ])...)

  type              = "ingress"
  security_group_id = each.value.security_group_id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_with_ipv6_cidr_blocks" {
  for_each = merge(flatten([
    for scg in var.security_groups : [
      for ingress in scg.ingresses : [
        for ipv6_cidr_block in ingress.ipv6_cidr_blocks : {
          "${scg.identifier}!${ingress.identifier}!${ipv6_cidr_block}" = merge(
            ingress,
            {
              security_group_id = lookup(aws_security_group.this, scg.identifier).id
              ipv6_cidr_blocks  = [ipv6_cidr_block]
            },
          )
        }
      ]
      if ingress.ipv6_cidr_blocks != null
    ]
  ])...)

  type              = "ingress"
  security_group_id = each.value.security_group_id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  ipv6_cidr_blocks  = each.value.ipv6_cidr_block

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_with_prefix_list_ids" {
  for_each = merge(flatten([
    for scg in var.security_groups : [
      for ingress in scg.ingresses : [
        for prefix_list_id in ingress.prefix_list_ids : {
          "${scg.identifier}!${ingress.identifier}!${prefix_list_id}" = merge(
            ingress,
            {
              security_group_id = lookup(aws_security_group.this, scg.identifier).id
              prefix_list_ids   = [prefix_list_id]
            },
          )
        }
      ]
      if ingress.prefix_list_ids != null
    ]
  ])...)

  type              = "ingress"
  security_group_id = each.value.security_group_id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  prefix_list_ids   = each.value.prefix_list_ids

  lifecycle {
    create_before_destroy = true
  }
}
