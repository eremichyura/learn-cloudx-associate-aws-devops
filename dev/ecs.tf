
data "aws_caller_identity" "current" {
}

data "aws_ecr_authorization_token" "cloudx_ecr_token" {
}

# ----------------------------------------- GHOST IMAGE -------------------------------------------------------#

resource "docker_image" "cloudx_ghost" {
  name = var.ghost_image_name

  provisioner "local-exec" {
    command     = <<-EOF
      docker pull ${var.ghost_image_name}:${var.ghost_image_tag}
      $image_id = docker images -q ${var.ghost_image_name}:${var.ghost_image_tag};
      docker tag $image_id ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region_name}.amazonaws.com/${var.ghost_image_name}:${var.ghost_image_tag}; 
      docker login --username ${data.aws_ecr_authorization_token.cloudx_ecr_token.user_name} --password ${data.aws_ecr_authorization_token.cloudx_ecr_token.password} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region_name}.amazonaws.com;
      docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region_name}.amazonaws.com/${var.ghost_image_name}:${var.ghost_image_tag};
    EOF
    interpreter = ["Powershell"]
  }
}
#region ---------------------------------- GHOST ECR --------------------------------------------------------#

resource "aws_ecr_repository" "cloudx_ghost" {
  name                 = var.aws_image_repository.name
  image_tag_mutability = var.aws_image_repository.image_tag_mutability
  tags                 = merge(var.aws_image_repository.tags, var.common_project_tags)

  encryption_configuration {
    encryption_type = var.aws_image_repository.encryption_type
  }
  image_scanning_configuration {
    scan_on_push = var.aws_image_repository.scan_on_push
  }
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.cloudx_ghost.name
  policy     = var.iam_ecr_policy
}

#endregion

# ----------------------------------------- GHOST ECS --------------------------------------------------------#

resource "aws_ecs_cluster" "cloudx_ghost" {
  name = var.ghost_ecs_service.name
  setting {
    name  = var.ghost_ecs_cluster.setting_name
    value = var.ghost_ecs_cluster.setting_value
  }
}

resource "aws_ecs_service" "cloudx_ghost" {
  name                              = var.ghost_ecs_service.name
  cluster                           = aws_ecs_cluster.cloudx_ghost.id
  launch_type                       = var.ghost_ecs_service.launch_type
  desired_count                     = var.ghost_ecs_service.desired_count
  health_check_grace_period_seconds = var.ghost_ecs_service.health_check_grace_period_seconds
  wait_for_steady_state             = var.ghost_ecs_service.wait_for_steady_state

  task_definition = aws_ecs_task_definition.cloudx_ghost_task.arn

  depends_on = [
    aws_db_instance.cloudx_ghost_mysql,
    aws_iam_role.cloudx_ghost_ecs_role,
    aws_lb_target_group.cloudx_ecs,
    aws_lb.cloudx_alb,
    aws_efs_file_system.cloudx_ghost_app_efs,
    aws_autoscaling_group.cloudx_asg
  ]

  load_balancer {
    target_group_arn = aws_lb_target_group.cloudx_ecs.arn
    container_name   = var.ghost_ecs_service.load_balancer_container_name
    container_port   = var.ghost_ecs_service.load_balancer_container_port
  }

  network_configuration {
    security_groups = ([
      [for x in aws_security_group.cloudx_security_groups :
      x.id if x.name == var.ghost_ecs_service.network_configuration_security_group && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
    ])
    subnets          = aws_subnet.ecs_privates.*.id
    assign_public_ip = var.ghost_ecs_service.assign_public_ip
  }
}

resource "aws_ecs_task_definition" "cloudx_ghost_task" {
  network_mode             = var.ghost_ecs_task_def.network_mode
  requires_compatibilities = var.ghost_ecs_task_def.requires_compatibilities
  memory                   = var.ghost_ecs_task_def.memory
  cpu                      = var.ghost_ecs_task_def.cpu
  execution_role_arn       = aws_iam_role.cloudx_ghost_ecs_role.arn
  task_role_arn            = aws_iam_role.cloudx_ghost_ecs_role.arn
  family                   = var.ghost_ecs_task_def.family
  tags                     = merge(var.ghost_ecs_task_def.tags, var.common_project_tags)

  depends_on = [
    docker_image.cloudx_ghost,
    aws_db_instance.cloudx_ghost_mysql,
    aws_iam_role.cloudx_ghost_ecs_role,
    aws_lb_target_group.cloudx_ecs,
    aws_lb.cloudx_alb,
    aws_efs_file_system.cloudx_ghost_app_efs,
    aws_autoscaling_group.cloudx_asg
  ]

  volume {
    name = var.ghost_ecs_task_def.volume_name
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.cloudx_ghost_app_efs.id
    }
  }

  container_definitions = jsonencode([{
    name                 = var.ghost_ecs_container_def.name
    region               = var.aws_region_name
    image                = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region_name}.amazonaws.com/${aws_ecr_repository.cloudx_ghost.name}:${var.ghost_image_tag}"
    essential            = var.ghost_ecs_container_def.essential
    ecs_cluster_fargate  = aws_ecs_cluster.cloudx_ghost.arn
    memory               = var.ghost_ecs_task_def.memory
    memoryReservation    = var.ghost_ecs_task_def.memory
    account_id           = data.aws_caller_identity.current.account_id
    cluster_region       = var.aws_region_name
    side_controller_port = var.ghost_ecs_container_def.portMappings_containerPort
    log_group            = aws_cloudwatch_log_group.log_group.name

    environment = [
      { "name" : "url", "value" : "http://${aws_lb.cloudx_alb.dns_name}" },
      { "name" : "database__client", "value" : "${var.ghost_ecs_container_def.environment_database__client}" },
      { "name" : "database__connection__host", "value" : "${aws_db_instance.cloudx_ghost_mysql.address}" },
      { "name" : "database__connection__user", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_user}" },
      { "name" : "database__connection__password", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_password}" },
      { "name" : "database__connection__database", "value" : "${jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string).database_name}" },
      { "name" : "NODE_ENV", "value" : "${var.ghost_ecs_container_def.environment_NODE_ENV}" }
    ]
    portMappings = [{
      protocol      = "${var.ghost_ecs_container_def.portMappings_protocol}"
      containerPort = "${var.ghost_ecs_container_def.portMappings_containerPort}"
    }]

    mountPoints = [{
      containerPath : "${var.ghost_ecs_container_def.mountPoints_containerPath}"
      sourceVolume : "${var.ghost_ecs_container_def.mountPoints_sourceVolume}"
    }]

    logConfiguration = {
      logDriver = "${var.ghost_ecs_container_def.logConfiguration_logDriver}",
      options = {
        awslogs-group         = "/ecs/ghost"
        awslogs-region        = "${var.aws_region_name}"
        awslogs-stream-prefix = "${var.ghost_ecs_container_def.logConfiguration_awslogs-stream-prefix}"
      }
    }
  }])
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/ghost"
  tags = merge(var.common_project_tags,
    {
      Name = "ghost"
    }
  )
}

