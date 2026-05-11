# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

terraform {
  required_version = ">= 1.0"

  required_providers {
    rhcs = {
      version = ">= 1.5.0"
      source  = "terraform-redhat/rhcs"
    }
  }
}