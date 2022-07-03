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

/*
variable "security_groups" {
  description = "Security Group List to create"
  type = list(tuple([string,string]))
}
*/
/*
security_group_rules = {
  "bastion" = [
    ["ingress","tcp","22","22",false,"149.34.244.153/32"],
    ["ingress","tcp","80","80",true,"149.34.244.153/32"]
  ]
}
*/
#security_group_rules2 = map(map(tuple([string,string,string,string,bool,string])))

#variable "security_group_rules" {
#
#}

/*

security_group_list = [
  {
    sg_name        = "bastion",
    sg_description = "allows access to bastion",
    rules = [
      {
        type            = "ingress",
        from_port       = "22",
        to_port         = "22",
        protocol        = "tcp",
        isSecurityGroup = false
      },
      {
        type            = "ingress",
        from_port       = "24",
        to_port         = "24",
        protocol        = "tcp"
        isSecurityGroup = true
      }
    ]
  }
]

*/

variable "security_group_list" {
  type = list(object(
    {
      sg_name        = string,
      sg_description = string,
      rules = list(object(
        {
          type            = string,
          from_port       = string,
          to_port         = string,
          protocol        = string,
          isSecurityGroup = bool,
          sd_id           = optional(string),
          cidr_block      = optional(string)
        }
      ))
    }
  ))
}



/*
security_groups = [
  {
    sg_name = "bastion",
    sg_description = "allows access to bastion"
    rules = [
      {
        type = "ingress",
        from_port = "22"
      },
      {
        type = "ingress",
        from_port = "24"
      }
    ]
  }
]

/*
security_group_list = {
  "bastion" = {
    sg_description = "allows access to bastion"
    rules = [
      ["ingress","tcp","22","22",false,"149.34.244.153/32"],
      ["ingress","tcp","80","80",false,"149.34.244.153/32"]
    ]
  }
}


/*
for_each = {
    for binding in flatten([
      for role_name, groups in var.rbac_roles : [
        for group in groups : [
          for ns in group.namespaces : [
            {
              binding_name = lower("${ns}-${group.group_name}-${role_name}")
              role         = role_name
              group_id     = group.group_id
              group_name   = group.group_name
              ns           = ns
            }
          ]
        ]
  ]]) : binding.binding_name => binding }


*/

/*
security_group_rules2 = {
  "bastion" = {

  }
  #"bastion2 = "
  }


/*
security_group_rules2 = {}

*/






/*
security_group_list = {
  "bastion" = {
    sg_description = "allows access to bastion"
    rules = [
      ["ingress","tcp","22","22",false,"149.34.244.153/32"],
      ["ingress","tcp","80","80",false,"149.34.244.153/32"]
    ]
  }
}

*/

/*
variable "security_group_rules" {
  type = map(list(tuple([string,string,string,string,bool,string ]))) 
}



/*
variable "security_group_list" {

  type = map(object({
              sg_description = string, 
              rules = list(tuple([string,string,string,string,bool,string ]))
            })
          )
  #type = map(string,list(tuple([string,string,string,string,bool,string ])))
}




  type = list(
          object(
            {
              sg_name = string, 
              sg_description = string, 
              rules = list(tuple([string,string,string,string,bool,string ]))
            }
          )
  ) 
  #type = map(string,list(tuple([string,string,string,string,bool,string ])))
}


variable "security_group_bastion_ingress_rules" {
  description = "List of ingress rules for bastiion sg"
  type = map(list(string))
}
*/
