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

resource "aws_security_group_rule" "egress" {
  for_each = merge([
    for scg in var.security_groups : {
      for egress in scg.egresses :
      "${scg.identifier}!${egress.identifier}" => merge(
        egress,
        {
          security_group_id = lookup(aws_security_group.this, scg.identifier).id
          destination_security_group_id = try(
            lookup(aws_security_group.this, egress.destination_security_group_identifier).id,
            egress.destination_security_group_id
          )
        },
      )
      if egress.cidr_blocks == null && egress.ipv6_cidr_blocks == null && egress.prefix_list_ids == null
    }
  ]...)

  type                     = "egress"
  security_group_id        = each.value.security_group_id
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.destination_security_group_id
  self                     = each.value.self

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "egress_with_cidr_blocks" {
  for_each = merge(flatten([
    for scg in var.security_groups : [
      for egress in scg.egresses : [
        for cidr_block in egress.cidr_blocks : {
          "${scg.identifier}!${egress.identifier}!${cidr_block}" = merge(
            egress,
            {
              security_group_id = lookup(aws_security_group.this, scg.identifier).id
              cidr_blocks       = [cidr_block]
            },
          )
        }
      ]
      if egress.cidr_blocks != null
    ]
  ])...)

  type              = "egress"
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

resource "aws_security_group_rule" "egress_with_ipv6_cidr_blocks" {
  for_each = merge(flatten([
    for scg in var.security_groups : [
      for egress in scg.egresses : [
        for ipv6_cidr_block in egress.ipv6_cidr_blocks : {
          "${scg.identifier}!${egress.identifier}!${ipv6_cidr_block}" = merge(
            egress,
            {
              security_group_id = lookup(aws_security_group.this, scg.identifier).id
              ipv6_cidr_blocks  = [ipv6_cidr_block]
            },
          )
        }
      ]
      if egress.ipv6_cidr_blocks != null
    ]
  ])...)

  type              = "egress"
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

resource "aws_security_group_rule" "egress_with_prefix_list_ids" {
  for_each = merge(flatten([
    for scg in var.security_groups : [
      for egress in scg.egresses : [
        for prefix_list_id in egress.prefix_list_ids : {
          "${scg.identifier}!${egress.identifier}!${prefix_list_id}" = merge(
            egress,
            {
              security_group_id = lookup(aws_security_group.this, scg.identifier).id
              prefix_list_ids   = [prefix_list_id]
            },
          )
        }
      ]
      if egress.prefix_list_ids != null
    ]
  ])...)

  type              = "egress"
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
