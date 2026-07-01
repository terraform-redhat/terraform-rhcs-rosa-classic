#!/bin/bash
# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

# Validates examples and the root module against the AWS provider floor and latest
# matching versions. Consumer floors in versions.tf are unchanged; see
# developer-docs/providers-and-versions.md.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSIONS_FILE="${ROOT_DIR}/versions.tf"
PLATFORM="${TF_VERIFY_PLATFORM:-linux_amd64}"

parse_aws_floor_from_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "0.0.0"
    return
  fi

  local constraint
  constraint="$(sed -n '/hashicorp\/aws/,/}/p' "$file" | grep 'version' | head -1 | sed -n 's/.*>= *\([0-9][0-9.]*\).*/\1/p' || true)"

  if [[ -z "$constraint" ]]; then
    echo "0.0.0"
  else
    echo "$constraint"
  fi
}

max_version() {
  printf '%s\n' "$@" | sort -V | tail -1
}

normalize_lock_version() {
  local version="$1"
  local segment_count

  segment_count="$(awk -F. '{print NF}' <<< "$version")"
  case "$segment_count" in
    1) echo "${version}.0.0" ;;
    2) echo "${version}.0" ;;
    *) echo "$version" ;;
  esac
}

parse_aws_effective_floor_from_lock() {
  python3 <<'PY'
import re
from pathlib import Path

text = Path(".terraform.lock.hcl").read_text()
match = re.search(
    r'provider "registry\.terraform\.io/hashicorp/aws" \{.*?constraints = "([^"]+)"',
    text,
    re.S,
)
if not match:
    raise SystemExit("aws provider constraints not found in .terraform.lock.hcl")
floors = re.findall(r">= (\d+\.\d+\.\d+)", match.group(1))
if not floors:
    raise SystemExit("no >= constraints found for aws provider")
print(max(floors, key=lambda value: tuple(int(part) for part in value.split("."))))
PY
}

pin_aws_lock_version() {
  local floor_version="$1"
  local lock_version

  lock_version="$(normalize_lock_version "$floor_version")"

  python3 - "$lock_version" <<'PY'
import re
import sys
from pathlib import Path

lock_version = sys.argv[1]
lock_file = Path(".terraform.lock.hcl")
text = lock_file.read_text()
text2, count = re.subn(
    r'(provider "registry\.terraform\.io/hashicorp/aws" \{\n  version     = )"[^"]+"',
    rf'\1"{lock_version}"',
    text,
    count=1,
)
if count != 1:
    raise SystemExit("aws provider block not found in .terraform.lock.hcl")
lock_file.write_text(text2)
PY
}

verify_directory() {
  local dir="$1"
  local pass="$2"

  echo "!! Validating ${dir} (${pass} AWS provider pass) !!"
  (
    cd "$dir"
    rm -rf .terraform .terraform.lock.hcl
    if [[ "$pass" == "floor" ]]; then
      terraform init -backend=false -input=false
      effective_floor="$(parse_aws_effective_floor_from_lock)"
      echo "== Merged AWS provider floor for ${dir}: ${effective_floor} =="
      pin_aws_lock_version "$effective_floor"
      terraform providers lock -platform="$PLATFORM" registry.terraform.io/hashicorp/aws
      rm -rf .terraform
      terraform init -backend=false -input=false -upgrade=false
    else
      terraform init -backend=false -input=false
    fi
    terraform validate
  )
}

main() {
  local root_floor module_max tested_latest

  root_floor="$(parse_aws_floor_from_file "$VERSIONS_FILE")"
  if [[ "$root_floor" == "0.0.0" ]]; then
    echo "Failed to parse root AWS provider floor from ${VERSIONS_FILE}" >&2
    exit 1
  fi

  module_max="0.0.0"
  while IFS= read -r vf; do
    module_max="$(max_version "$module_max" "$(parse_aws_floor_from_file "$vf")")"
  done < <(find "$ROOT_DIR/modules" -name versions.tf -print | sort)

  tested_latest="$(grep 'tested_aws_provider_latest' "$VERSIONS_FILE" | sed -n 's/.*= \([0-9.]*\).*/\1/p' || true)"

  echo "== Root AWS provider floor: ${root_floor} =="
  echo "== In-repo module tree max AWS floor: ${module_max} =="
  if [[ -n "$tested_latest" ]]; then
    echo "== Documented tested AWS provider latest: ${tested_latest} =="
  fi
  echo "== Floor pass pins the merged >= constraints after init (includes registry modules) =="

  for pass in floor latest; do
    echo "== AWS provider pass: ${pass} =="
    for d in "$ROOT_DIR"/examples/*/; do
      [[ -d "$d" ]] || continue
      verify_directory "$d" "$pass"
    done
    verify_directory "$ROOT_DIR" "$pass"
  done
}

main "$@"
