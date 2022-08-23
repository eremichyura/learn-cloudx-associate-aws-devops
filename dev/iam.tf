#----------------------------------  IAM POLICY FOR GHOST APP----------------------------------#

data "aws_iam_policy_document" "cloudx_ghost_app_policy_document" {
  dynamic "statement" {
    for_each = var.iam_policy.statements
    content {
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      effect    = statement.value["effect"]
    }
  }
}

resource "aws_iam_policy" "cloudx_ghost_app_iam_policy" {
  description = var.iam_policy.description
  name        = var.iam_policy.name
  path        = var.iam_policy.path
  tags        = merge(var.common_project_tags, var.iam_policy.policy_tags)
  policy      = data.aws_iam_policy_document.cloudx_ghost_app_policy_document.json
}

#----------------------------------  IAM POLICY FOR GHOST ECS----------------------------------#

data "aws_iam_policy_document" "cloudx_ghost_ecs" {
  dynamic "statement" {
    for_each = var.iam_ecs_policy.statements
    content {
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      effect    = statement.value["effect"]
    }
  }
}

resource "aws_iam_policy" "cloudx_ghost_ecs" {
  description = var.iam_ecs_policy.description
  name        = var.iam_ecs_policy.name
  path        = var.iam_ecs_policy.path
  tags        = merge(var.common_project_tags, var.iam_ecs_policy.policy_tags)
  policy      = data.aws_iam_policy_document.cloudx_ghost_ecs.json
}

#----------------------------------  IAM ROLE AND POLICY FOR GHOST APP -----------------------------------#

data "aws_iam_policy_document" "cloudx_ghost_app_role_policy" {
  dynamic "statement" {
    for_each = var.iam_role.statements
    content {
      actions = statement.value["actions"]
      effect  = statement.value["effect"]
      dynamic "principals" {
        for_each = statement.value["principals"]
        content {
          type        = principals.key
          identifiers = principals.value
        }
      }
    }
  }
}

resource "aws_iam_role" "cloudx_ghost_app_role" {
  name               = var.iam_role.name
  assume_role_policy = data.aws_iam_policy_document.cloudx_ghost_app_role_policy.json
  tags               = merge(var.common_project_tags, var.iam_role.role_tags)
}

#----------------------------------  IAM ROLE AND POLICY FOR GHOST ECS -----------------------------------#

data "aws_iam_policy_document" "cloudx_ghost_ecs_role" {
  dynamic "statement" {
    for_each = var.iam_ecs_role.statements
    content {
      actions = statement.value["actions"]
      effect  = statement.value["effect"]
      dynamic "principals" {
        for_each = statement.value["principals"]
        content {
          type        = principals.key
          identifiers = principals.value
        }
      }
    }
  }
}

resource "aws_iam_role" "cloudx_ghost_ecs_role" {
  name               = var.iam_ecs_role.name
  assume_role_policy = data.aws_iam_policy_document.cloudx_ghost_ecs_role.json
  tags               = merge(var.common_project_tags, var.iam_ecs_role.role_tags)
}

#-------------------------  ASSIGN POLICY AND ROLE  ------------------------------#

resource "aws_iam_role_policy_attachment" "cloudx_ghost_app_role_policy_assign" {
  role       = aws_iam_role.cloudx_ghost_app_role.name
  policy_arn = aws_iam_policy.cloudx_ghost_app_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudx_ghost_ecs" {
  role       = aws_iam_role.cloudx_ghost_ecs_role.name
  policy_arn = aws_iam_policy.cloudx_ghost_ecs.arn
}

#---------------------------   INSTANCE PROFILE  ----------------------------------#

resource "aws_iam_instance_profile" "cloudx_ghost_app_instance_profile" {
  name = var.instance_profile.Name
  role = aws_iam_role.cloudx_ghost_app_role.name
  tags = merge(var.common_project_tags, var.instance_profile.tags)
}

resource "aws_iam_instance_profile" "cloudx_ghost_ecs_instance_profile" {
  name = var.instance_ecs_profile.Name
  role = aws_iam_role.cloudx_ghost_ecs_role.name
  tags = merge(var.common_project_tags, var.instance_ecs_profile.tags)
}
