#----------------------  VPC ENDPOINTS  -------------------------------#

# S3 #
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.cloudx_vpc.id
  service_name      = "com.amazonaws.${var.aws_region_name}.s3"
  route_table_ids   = [aws_route_table.cloudx_database_private.id]
  auto_accept       = true
  vpc_endpoint_type = "Gateway"

  tags = merge(var.common_project_tags,
    {
      Name = "s3-vpc-endpoint"
    }
  )
}

# ECR API #
resource "aws_vpc_endpoint" "ecr-endpoint" {
  vpc_id              = aws_vpc.cloudx_vpc.id
  service_name        = "com.amazonaws.${var.aws_region_name}.ecr.api"
  subnet_ids          = aws_subnet.ecs_privates.*.id
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"

  security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == "vpc_endpoints" && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])

  tags = merge(var.common_project_tags,
    {
      Name = "ecr-vpc-endpoint"
    }
  )
}

# DKR #
resource "aws_vpc_endpoint" "docker-endpoint" {
  vpc_id              = aws_vpc.cloudx_vpc.id
  service_name        = "com.amazonaws.${var.aws_region_name}.ecr.dkr"
  subnet_ids          = aws_subnet.ecs_privates.*.id
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"

  security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == "vpc_endpoints" && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])

  tags = merge(var.common_project_tags,
    {
      Name = "docker_ecr-vpc-endpoint"
    }
  )
}

# EFS #
resource "aws_vpc_endpoint" "efs-endpoint" {
  vpc_id              = aws_vpc.cloudx_vpc.id
  service_name        = "com.amazonaws.${var.aws_region_name}.elasticfilesystem"
  subnet_ids          = aws_subnet.ecs_privates.*.id
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"

  security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == "vpc_endpoints" && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])

  tags = merge(var.common_project_tags,
    {
      Name = "efs-vpc-endpoint"
    }
  )
}

# CloudWatch logs #
resource "aws_vpc_endpoint" "cloudwatch_logs-endpoint" {
  vpc_id              = aws_vpc.cloudx_vpc.id
  service_name        = "com.amazonaws.${var.aws_region_name}.logs"
  subnet_ids          = aws_subnet.ecs_privates.*.id
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"

  security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == "vpc_endpoints" && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])

  tags = merge(var.common_project_tags,
    {
      Name = "cloudwatch-vpc-endpoint"
    }
  )
}

# SecretsManager #
resource "aws_vpc_endpoint" "secretsmanager-endpoint" {
  vpc_id              = aws_vpc.cloudx_vpc.id
  service_name        = "com.amazonaws.${var.aws_region_name}.secretsmanager"
  subnet_ids          = aws_subnet.ecs_privates.*.id
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"

  security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == "vpc_endpoints" && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])
  tags = merge(var.common_project_tags,
    {
      Name = "secretsmanager-vpc-endpoint"
    }
  )
}

# KMS #
resource "aws_vpc_endpoint" "kms-endpoint" {
  vpc_id              = aws_vpc.cloudx_vpc.id
  service_name        = "com.amazonaws.${var.aws_region_name}.kms"
  subnet_ids          = aws_subnet.ecs_privates.*.id
  private_dns_enabled = true
  auto_accept         = true
  vpc_endpoint_type   = "Interface"

  security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == "vpc_endpoints" && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])

  tags = merge(var.common_project_tags,
    {
      Name = "kms-vpc-endpoint"
    }
  )
}
