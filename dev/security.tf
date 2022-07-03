resource "aws_security_group" "cloudx_security_groups" {
  count       = length(var.security_group_list)
  name        = var.security_group_list[count.index].sg_name
  vpc_id      = aws_vpc.cloudx_vpc.id
  description = var.security_group_list[count.index].sg_description
  tags        = var.common_project_tags
  #tags = merge(var.common_project_tags,{
  #  Name = element(element(var.security_groups,count.index),0)
  #})
}

locals {
  groups = { for s in aws_security_group.cloudx_security_groups : s.name => s.id }
  rules = {
    for binding in flatten([
      for r in var.security_group_list : [
        for a in r.rules : [
          {
            id = "${r.sg_name}-${a.type}-${a.to_port}-${a.protocol}"
            #id = "${timestamp()}-${a.to_port}"
            group   = r.sg_name,
            to_port = a.to_port,
            #sd_id      = a.sd_id == null ? null : local.groups[a.sd_id],
            sd_id      = a.sd_id == null ? null : local.groups[a.sd_id],
            cidr_block = a.cidr_block == null ? null : a.cidr_block
          }
          #          }
        ]
      ]
  ]) : binding.id => binding }
}

/*
resource "aws_security_group_rule" "cloudx_security_group_rules" {
  for_each = {
    for binding in flatten([
      for r in var.security_group_list : [
        for a in r.rules : [
          {
            id      = "${r.sg_name}-${a.type}-${a.to_port}-${a.protocol}"
            sg_name = r.sg_name,
            #sg_description = binding.description,
            rule_type  = a.type,
            to_port    = a.to_port,
            from_port  = a.from_port,
            sd_id      = a.sd_id == null ? null : local.groups[a.sd_id],
            cidr_block = a.cidr_block == null ? null : a.cidr_block,
            protocol   = a.protocol


          }
        ]
      ]
  ]) : binding.id => binding }
  security_group_id = local.groups[each.value.sg_name]
  #security_group_id = local.groups["sg_name"]
  type                     = each.value.rule_type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_block == null ? [null] : [each.value.cidr_block]
  source_security_group_id = each.value.sd_id == null ? null : each.value.sd_id

*/


/*
  security_group_id = local.groups["sg_name"]
  type = each.value.rule_type
  from_port = each.value.from_port
  to_port =  each.value.to_port
  protocol =  each.value.protocol
*/


/*
rules = {
    for r in flatten([
      for sg in var.security_group_list : [
        for sg_content in sg : [
          for rule in sg_content.rules : [
            {
              rules_id = "${sg_content.name}-${rule.type}-${rule.to_port}-${rule.from_port}"
              sg_name = sg_content.sg_name
              #sg_description = sg_content.description
              rule_type = rule.type
              to_port = rule.to_port
              protocol = rule.protocol
              from_prot = rule.from_port
              #sg_id = local.groups[sg_content.sg_name]
            }
            
          ]
        ]
      ] 
    ]) : r.rules_id => r }
*/

output "groups" {
  value = local.groups

}

output "rules" {
  value = local.rules

}




/*
resource "aws_security_group_rule" "cloudx_security_group_rules" {
  for_each = {
    for rules in flatten([
      for sg in var.security_group_list : [
        for sg_content in sg : [
          for rule in sg_content.rules[*] : [
            {
              rules_id = "${sg_content.name}-${rule.type}-${rule.to_port}-${rule.from_port}"
              sg_name = sg_content.sg_name
              #sg_description = sg_content.description
              rule_type = rule.type
              to_port = rule.to_port
              protocol = rule.protocol
              from_prot = rule.from_port
              #sg_id = local.groups[sg_content.sg_name]
            }
            
          ]
        ]
      ] 
    ]) : rules.rules_id => rules }
  security_group_id = local.groups["sg_name"]
  type = each.value.rule_type
  from_port = each.value.from_port
  to_port =  each.value.to_port
  protocol =  each.value.protocol
}

/*
resource "aws_security_group_rule" "cloudx_security_group_rules" {
for_each = security_group_rules
security_group_id = local.groups["each.key"]
for a,b,c,d,e,f in each.value :
 # security_group_id = aws_security_group.cloudx_security_groups[0].id
  type = "ingress"
 # cidr_blocks = ["149.34.244.153/32"]
  from_port = "22"
  to_port   = "22"
  protocol  = "tcp"
  #source_security_group_id = local.groups["bastion"]
}



#resource "aws_security_group_rule" "cloudx_security_group_rules" {
#  for_each = var.security_group_rules
#aws_security_group.cloudx_security_groups[0].security_group_id

#index = index(aws_security_group.cloudx_security_groups,"bastion")

#aws_security_group.cloudx_security_groups[0].security_group_id

#index = (aws_security_group.cloudx_security_groups)

#security_group_id = aws_security_group.cloudx_security_groups[0]
#  security_group_id = aws_security_group.cloudx_security_groups[0]
 #cloudx_security_groups[0]
 #aws_security_group.cloudx_security_groups
  
#}

/*
resource "aws_security_group" "cloudx_bastion" {
  vpc_id = aws_vpc.cloudx_vpc.id
  description = "allows access to bastion"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["149.34.244.153/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "cloudx_ec2_pool" {
  vpc_id      = aws_vpc.cloudx_vpc.id
  description = "allows access to ec2 instances"

    ingress {
        from_port       = 2368
        to_port         = 2368
        protocol        = "tcp"
        #security_groups = ["sg-03591b05d8b4bc3da"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
       # security_groups = ["sg-0b53266002724604b"]
    }

    ingress {
        from_port       = 2049
        to_port         = 2049
        protocol        = "tcp"
        cidr_blocks     = [var.vpc_cidr_block]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

  tags = merge(var.common_project_tags,{
    Name = "ec2_pool"
  })
}
*/
