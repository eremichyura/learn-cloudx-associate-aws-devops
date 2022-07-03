terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }
  }

  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region     = var.aws_region_name
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key
}
