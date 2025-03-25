terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.0"
    }
  }
  required_version = "~> 1.11.0"
  backend "s3" {}
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = var.profile
}


## Modules
module "vpc" {
  source         = "./modules/vpc"
  prefix         = var.prefix
  env            = var.env
  vpc_cidr       = "10.1.0.0/16"
  req_subnet_num = 2
}
