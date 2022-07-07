/* TODO refactor efs traget creation

data "aws_subnets" "cloudx_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.cloudx_vpc.id]
  }
}
output "cloudx_aws_subnets_ids" {
  value = data.aws_subnets.cloudx_subnets.ids
}
*/

resource "aws_efs_file_system" "cloudx_ghost_app_efs" {
  tags = merge(var.common_project_tags, var.efs.tags)
}

resource "aws_efs_mount_target" "cloudx_ghost_app_efs_target_a" {
  file_system_id = aws_efs_file_system.cloudx_ghost_app_efs.id
  subnet_id      = aws_subnet.cloudx_subnet_public_a.id
}

resource "aws_efs_mount_target" "cloudx_ghost_app_efs_target_b" {
  file_system_id = aws_efs_file_system.cloudx_ghost_app_efs.id
  subnet_id      = aws_subnet.cloudx_subnet_public_b.id
}

resource "aws_efs_mount_target" "cloudx_ghost_app_efs_target_c" {
  file_system_id = aws_efs_file_system.cloudx_ghost_app_efs.id
  subnet_id      = aws_subnet.cloudx_subnet_public_c.id
}


/* TODO refactor subnets creation and then efs targets:
resource "aws_efs_mount_target" "cloudx_ghost_app_efs_targets" {
  for_each = tomap(
    { for x in data.aws_subnets.cloudx_subnets.ids : x => x }
  )
  #for_each       = tomap(data.aws_subnets.cloudx_subnets.ids)
  file_system_id = aws_efs_file_system.cloudx_ghost_app_efs.id
  subnet_id      = each.value
}
*/
