terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # For a team/portfolio upgrade, move state to S3 + DynamoDB locking:
  # backend "s3" {
  #   bucket         = "my-tfstate-bucket"
  #   key            = "fastapi-apprunner/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "tfstate-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}
