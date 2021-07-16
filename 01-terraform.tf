terraform {
  # Terraform version
  required_version = ">= 0.14.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    # AWS provider version
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.25.0"
    }
  }
}