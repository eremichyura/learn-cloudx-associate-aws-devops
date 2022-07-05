#########################################################################
#               BASE SETTINGS                                           #
#########################################################################

variable "aws_region_name" {
  description = "AWS region"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "common_project_tags" {
  description = "Common tags that used to identify project end enviroment"
  type        = map(string)
}

#########################################################################
#                               VPC                                     #
#########################################################################

#----------------------------  VPC  ------------------------------------#

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}
variable "vpc_dns_support_enabled" {
  description = "Enable DNS support"
  type        = bool
}
variable "vpc_dns_hostnames_enabled" {
  description = "Enable DNS hostnames"
  type        = bool
}
variable "vpc_tags" {
  description = "VPC tags"
  type        = map(string)
}

#-----------------------------  IGW  -----------------------------------#

variable "igw_tags" {
  description = "Intern Gateway tags"
  type        = map(string)
}

#----------------------------SUBNETS -----------------------------------#

####### subnet A
variable "subnet_public_a_cidr" {
  description = "CIDR block of public subnet A"
  type        = string
}

variable "subnet_public_a_az" {
  description = "Availability zone for public subnet A"
  type        = string
}

variable "subnet_public_a_tags" {
  description = "Tags for public subnet A"
  type        = map(string)
}

####### subnet B
variable "subnet_public_b_cidr" {
  description = "CIDR block of public subnet B"
  type        = string
}

variable "subnet_public_b_az" {
  description = "Availability zone for public subnet B"
  type        = string
}

variable "subnet_public_b_tags" {
  description = "Tags for public subnet B"
  type        = map(string)
}

####### subnet C
variable "subnet_public_c_cidr" {
  description = "CIDR block of public subnet C"
  type        = string
}

variable "subnet_public_c_az" {
  description = "Availability zone for public subnet C"
  type        = string
}

variable "subnet_public_c_tags" {
  description = "Tags for public subnet C"
  type        = map(string)
}

#----------------------  ROUTE TABLES  -------------------------------#

variable "public_rt_route_cidr" {
  description = "Public route table route CIDR block"
  type        = string
}

variable "public_rt_tags" {
  description = "Tags for public route table"
  type        = map(string)
}

#########################################################################
#                           SECURITY                                    #
#########################################################################

#-------------------------  SECURITY GROUPS  ---------------------------#

variable "security_groups_with_rules" {
  description = <<EOT
  How to to set groups and rules:

    "sg_group_1_name" = {
      description = "sg description",
      sg_tags = {
        tag_name = "tag value",
        tag2_name = "tag 2 value",
        ...etc
      },
      rules = [
        [rule_type,protocol,from_port,to_port,source_type,source],
        [rule_type,protocol,from_port,to_port,source_type,source],
        etc...
      ]
    }
    ...etc

  example:
    "bastion" = {
      description = "allows access to bastion",
      sg_tags = {
        Name = "bastion"
      }
      rules = [
        ["ingress", "tcp", "22", "22", "cidr", "195.56.119.209/32"],
        ["egress", "-1", "0", "0", "cidr", "0.0.0.0/0"]
      ]
    }
  EOT

  type = map(
    object({
      description = string,
      sg_tags     = map(string),
      rules       = list(list(string))
    })
  )
}

