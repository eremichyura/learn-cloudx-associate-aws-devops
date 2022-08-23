terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.19.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }
}
provider "aws" {
  region     = var.aws_region_name
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key
}

provider "docker" {
  host = var.docker_host

  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region_name}.amazonaws.com"
    username = data.aws_ecr_authorization_token.cloudx_ecr_token.user_name
    password = data.aws_ecr_authorization_token.cloudx_ecr_token.password
  }

  registry_auth {
    address  = var.docker_registry_auth.address
    username = var.docker_registry_auth.username
    password = var.docker_registry_auth.password
  }
}
