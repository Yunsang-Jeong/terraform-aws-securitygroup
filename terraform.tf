terraform {
  # Terraform version
  required_version = ">= 1.6.0"

  required_providers {
    # AWS provider version
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}