# TODO: need to refactor
#----------------------------  ALB  ------------------------------------#

resource "aws_lb" "cloudx_alb" {
  name               = var.alb.name
  load_balancer_type = var.alb.load_balancer_type
  internal           = var.alb.internal
  subnets = [
    aws_subnet.cloudx_subnet_public_a.id,
    aws_subnet.cloudx_subnet_public_b.id,
    aws_subnet.cloudx_subnet_public_c.id
  ]
  security_groups = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == var.alb.alb_security_group_name && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])
  tags = merge(var.alb.tags, var.common_project_tags)
}

#------------------------  TARGET_GROUP  -------------------------------#

resource "aws_lb_target_group" "cloudx_alb_target_group" {
  name     = var.alb_target_group.name
  port     = var.alb_target_group.port
  protocol = var.alb_target_group.protocol
  vpc_id   = aws_vpc.cloudx_vpc.id
  tags     = merge(var.alb_target_group.tags, var.common_project_tags)
}

#------------------------  ALB_LISTENER  -------------------------------#


resource "aws_lb_listener" "cloudx_alb_listener" {
  load_balancer_arn = aws_lb.cloudx_alb.arn
  port              = var.alb_listener.port
  protocol          = var.alb_listener.protocol
  tags              = merge(var.alb_listener.tags, var.common_project_tags)
  default_action {
    type = var.alb_listener.default_action_type
    forward {
      target_group {
        arn    = aws_lb_target_group.cloudx_alb_target_group.arn
        weight = var.alb_listener.default_action_weight
      }
    }
  }
}
