#----------------------------------  IAM POLICY ----------------------------------#

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

#----------------------------------  IAM ROLE  -----------------------------------#
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
}
