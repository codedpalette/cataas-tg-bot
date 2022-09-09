terraform {
  required_version = ">= 1.2.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.21.0"
    }
  }
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

provider "docker" {}
