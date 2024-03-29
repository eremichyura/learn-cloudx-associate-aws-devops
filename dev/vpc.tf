#-------------------------  VPC  -------------------------------------#

resource "aws_vpc" "cloudx_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.vpc_dns_support_enabled
  enable_dns_hostnames = var.vpc_dns_hostnames_enabled
  tags                 = merge(var.common_project_tags, var.vpc_tags)
}

#---------------------------SUBNETS ----------------------------------#

resource "aws_subnet" "cloudx_subnet_public_a" {
  vpc_id            = aws_vpc.cloudx_vpc.id
  cidr_block        = var.subnet_public_a_cidr
  availability_zone = var.subnet_public_a_az
  tags              = merge(var.common_project_tags, var.subnet_public_a_tags)
}

resource "aws_subnet" "cloudx_subnet_public_b" {
  vpc_id            = aws_vpc.cloudx_vpc.id
  cidr_block        = var.subnet_public_b_cidr
  availability_zone = var.subnet_public_b_az
  tags              = merge(var.common_project_tags, var.subnet_public_b_tags)
}

resource "aws_subnet" "cloudx_subnet_public_c" {
  vpc_id            = aws_vpc.cloudx_vpc.id
  cidr_block        = var.subnet_public_c_cidr
  availability_zone = var.subnet_public_c_az
  tags              = merge(var.common_project_tags, var.subnet_public_c_tags)
}

resource "aws_subnet" "databases" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.cloudx_vpc.id
  cidr_block        = var.database_subnets[count.index].cidr_block
  availability_zone = var.database_subnets[count.index].availability_zone
  tags              = merge(var.common_project_tags, var.database_subnets[count.index].tags)
}

resource "aws_subnet" "ecs_privates" {
  count = length(var.ecs_private_subnets)

  vpc_id            = aws_vpc.cloudx_vpc.id
  cidr_block        = var.ecs_private_subnets[count.index].cidr_block
  availability_zone = var.ecs_private_subnets[count.index].availability_zone
  tags              = merge(var.common_project_tags, var.ecs_private_subnets[count.index].tags)
}

#---------------------------  IGW  -----------------------------------#

resource "aws_internet_gateway" "cloudx_igw" {
  vpc_id = aws_vpc.cloudx_vpc.id
  tags   = merge(var.common_project_tags, var.igw_tags)
}

#----------------------  ROUTE TABLES  -------------------------------#

resource "aws_route_table" "cloudx_public_rt" {
  vpc_id = aws_vpc.cloudx_vpc.id
  route {
    cidr_block = var.public_rt_route_cidr
    gateway_id = aws_internet_gateway.cloudx_igw.id
  }
  depends_on = [
    aws_internet_gateway.cloudx_igw
  ]
  tags = merge(var.common_project_tags, var.public_rt_tags)
}

resource "aws_route_table_association" "cloudx_public_rt_association_a" {
  route_table_id = aws_route_table.cloudx_public_rt.id
  subnet_id      = aws_subnet.cloudx_subnet_public_a.id
}

resource "aws_route_table_association" "cloudx_public_rt_association_b" {
  route_table_id = aws_route_table.cloudx_public_rt.id
  subnet_id      = aws_subnet.cloudx_subnet_public_b.id
}

resource "aws_route_table_association" "cloudx_public_rt_association_c" {
  route_table_id = aws_route_table.cloudx_public_rt.id
  subnet_id      = aws_subnet.cloudx_subnet_public_c.id
}

resource "aws_route_table" "cloudx_database_private" {
  vpc_id = aws_vpc.cloudx_vpc.id
  depends_on = [
    aws_subnet.databases,
    aws_internet_gateway.cloudx_igw
  ]
  tags = merge(var.common_project_tags, var.database_private_route_table_tags)
}

resource "aws_route_table_association" "cloudx_private_databases" {
  count = length(var.database_subnets)

  route_table_id = aws_route_table.cloudx_database_private.id
  subnet_id      = aws_subnet.databases[count.index].id
}

resource "aws_route_table_association" "cloudx_private_ecs" {
  count = length(var.ecs_private_subnets)

  route_table_id = aws_route_table.cloudx_database_private.id
  subnet_id      = aws_subnet.ecs_privates[count.index].id
}
