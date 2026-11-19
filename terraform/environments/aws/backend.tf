terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Production Remote State (Uncomment after creating S3 bucket & DynamoDB table)
  # backend "s3" {
  #   bucket         = "ideaboard-tf-state-aws"
  #   key            = "aws/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}