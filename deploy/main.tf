terraform {
  required_version = ">= 1.2.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = local.aws_profile

  default_tags {
    tags = {
      project : local.service_name
    }
  }
}
