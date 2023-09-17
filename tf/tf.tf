terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
  backend "s3" {
    bucket  = "terraform-0"
    key     = "lambda-certbot.terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  app_name = "lambda-certbot"
}