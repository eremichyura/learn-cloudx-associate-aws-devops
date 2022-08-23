#########################################################################
#                              ASG                                      #
#########################################################################

#-----------------------  CLOUD INIT CONFIG  ---------------------------#
locals {

  script_template = templatefile("${path.root}/install.tftpl", {
    DB_NAME         = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_name
    DB_PASSWORD     = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_password
    DB_USER         = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_user
    DB_URL          = "${aws_db_instance.cloudx_ghost_mysql.address}"
    LB              = var.alb.name
    GHOST_IMAGE_TAG = "${var.ghost_image_tag}"
  })
}

data "cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = [
        {
          encoding    = "text/plain"
          content     = <<-EOT
            [default]
            aws_access_key_id = ${var.aws_access_key_id}
            aws_secret_access_key = ${var.aws_secret_key}
            EOT
          path        = "/root/.aws/credentials"
          owner       = "root:root"
          permissions = "0644"
        },
      ]
    })
  }

  part {
    filename     = "init-shellscript"
    content_type = "text/x-shellscript"
    content      = local.script_template
  }
}

#-------------------------  LAUNCH TEMPLATE  ---------------------------#

resource "aws_launch_template" "cloudx_ec2_launch_template" {
  name                                 = var.launch_template.name
  instance_type                        = var.launch_template.instance_type
  image_id                             = var.launch_template.image_id
  key_name                             = aws_key_pair.cloudx_ghost-ec2-pool.key_name
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  network_interfaces {
    device_index                = var.launch_template.network_interfaces_device_index
    associate_public_ip_address = var.launch_template.network_interfaces_associate_public_ip_address
    security_groups = ([
      [for x in aws_security_group.cloudx_security_groups :
      x.id if x.name == var.launch_template.network_interfaces_ec2_pool_name && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
    ])
  }
  user_data = data.cloudinit_config.cloud_init.rendered
}

#------------------------------  ASG  --------------------------------#

resource "aws_autoscaling_group" "cloudx_asg" {
  name               = var.asg.name
  capacity_rebalance = var.asg.capacity_rebalance
  desired_capacity   = var.asg.desired_capacity
  max_size           = var.asg.max_size
  min_size           = var.asg.min_size

  health_check_type         = var.asg.health_check_type
  health_check_grace_period = 600
  target_group_arns         = [aws_lb_target_group.cloudx_alb_target_group.arn]
  vpc_zone_identifier       = [aws_subnet.cloudx_subnet_public_a.id, aws_subnet.cloudx_subnet_public_b.id, aws_subnet.cloudx_subnet_public_c.id]

  launch_template {
    id      = aws_launch_template.cloudx_ec2_launch_template.id
    version = var.asg.launch_template_version
  }
}
