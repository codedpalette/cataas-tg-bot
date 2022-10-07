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
      Project = local.service_name
    }
  }
}

variable "telegram_bot_token" {
  description = "Telegram bot token"
  type        = string
  sensitive   = true
}

locals {
  service_name = "cataas-bot"
  aws_profile  = "cataas-bot"

  registry_url = split("/", aws_ecr_repository.ecr.repository_url)[0]

  ec2_instance_connect_cidr = ["18.206.107.24/29"]
  api_gateway_cidr = [
    "3.216.135.0/24",
    "3.216.136.0/21",
    "3.216.144.0/23",
    "3.216.148.0/22",
    "3.235.26.0/23",
    "3.235.32.0/21",
    "3.238.166.0/24",
    "3.238.212.0/22",
    "44.206.4.0/22",
    "44.210.64.0/22"
  ]
}
