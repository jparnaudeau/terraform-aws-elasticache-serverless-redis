#######################################
# define the provider
#######################################
provider "aws" {
  region = var.aws_region
}

#######################################
# define the provider
#######################################
terraform {
  required_version = ">= 1.0.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }

}