#!/bin/bash

set -e

for d in . modules/* examples/*; do
  echo $d
  terraform-docs -c .terraform-docs.yml $d
done
