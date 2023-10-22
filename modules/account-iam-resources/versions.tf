terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    rhcs = {
      version = "1.4.0-prerelease.3"
      source  = "terraform-redhat/rhcs"
    }
  }
}
