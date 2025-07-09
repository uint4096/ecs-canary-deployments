terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "main" {
  name = "canary-cluster"

  tags = {
    Name        = "canary-cluster"
    Environment = "dev"
  }
}

resource "aws_ecr_repository" "minimal" {
  name                 = "minimal"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
