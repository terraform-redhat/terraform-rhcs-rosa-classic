terraform {
  required_version = ">= 1.0"

  required_providers {
    rhcs = {
      version = ">= 1.4.0"
      source  = "terraform-redhat/rhcs"
    }
  }
}
