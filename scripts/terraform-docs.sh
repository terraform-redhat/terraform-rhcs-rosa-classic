#!/bin/bash
# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0


set -e

for d in . modules/* examples/*; do
  echo $d
  rm -rf $d/.terraform $d/.terraform.lock.hcl
  terraform-docs -c .terraform-docs.yml $d
done
