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

  application_port          = "80"
  application_internal_port = "80"

  registry_url = split("/", aws_ecr_repository.ecr.repository_url)[0]
}
