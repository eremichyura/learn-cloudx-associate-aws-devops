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
  }
}
provider "aws" {
  region     = var.aws_region_name
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key
}
