terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "4.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_ecr_repository" "node_app_repo" {
  name = "node-helloworld"
}