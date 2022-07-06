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
            sg_name     = sg_key,
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

  source_security_group_id = (
    each.value.source_type == "sg" ?
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == each.value.source && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
    : null
  )
  cidr_blocks = each.value.source_type == "cidr" ? [each.value.source] : null
  security_group_id = (
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == each.value.sg_name && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  )
  protocol  = each.value.protocol
  to_port   = each.value.to_port
  from_port = each.value.from_port
  type      = each.value.type
}

#-------------------------  SSH KEY PAIR  ---------------------------#

resource "aws_key_pair" "cloudx_ghost-ec2-pool" {
  key_name   = var.ssh_public_key.name
  public_key = var.ssh_public_key.public_key
  tags       = merge(var.common_project_tags, var.ssh_public_key.key_tags)
}
