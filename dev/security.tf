locals {
  sg_maps = { for s in aws_security_group.cloudx_security_groups : s.name => s.id }
}

#------------------------  SECURITY GROUPS ------------------------------------#

resource "aws_security_group" "cloudx_security_groups" {
  for_each    = var.security_groups_with_rules
  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.cloudx_vpc.id
  tags        = merge(var.common_project_tags, each.value.sg_tags)
}

resource "aws_security_group_rule" "security_groups_rules" {
  for_each = {
    for index, rules in flatten([
      for sg_key, sg_object in var.security_groups_with_rules : [
        for rule in sg_object.rules : [
          {
            sg          = sg_key,
            type        = rule[0],
            protocol    = rule[1],
            from_port   = rule[2],
            to_port     = rule[3],
            source_type = rule[4],
            source      = rule[5]
          }
        ]
      ]
    ]) : index => rules
  }
  source_security_group_id = each.value.source_type == "sg" ? local.sg_maps[each.value.source] : null
  cidr_blocks              = each.value.source_type == "cidr" ? [each.value.source] : null
  security_group_id        = local.sg_maps[each.value.sg]
  protocol                 = each.value.protocol
  to_port                  = each.value.to_port
  from_port                = each.value.from_port
  type                     = each.value.type
}


