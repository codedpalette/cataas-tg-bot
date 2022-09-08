terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "cataas-bot"

  default_tags {
    tags = {
      project : "cataas-bot"
    }
  }
}
