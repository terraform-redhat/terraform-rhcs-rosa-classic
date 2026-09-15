#!/bin/bash
# Copyright Red Hat
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXAMPLES_DIR="${REPO_ROOT}/examples"
RUN_EXAMPLE="${SCRIPT_DIR}/run-example.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ALL_EXAMPLES=(
    "ocm-role"
    "rosa-classic-private-with-autoscaler-unmanaged-oidc-byo-vpc"
    "rosa-classic-public-with-byo-vpc-byo-iam-byo-oidc"
    "rosa-classic-public-with-byo-vpc"
    "rosa-classic-public-with-idp-machine-pools"
    "rosa-classic-public-with-multiple-machinepools-and-idps"
    "rosa-classic-public-with-shared-vpc"
    "rosa-classic-public-with-unmanaged-oidc"
    "rosa-classic-public"
)

usage() {
    cat <<EOF
Usage:
    ./run-all-examples.sh [options]

Options:
    --apply-only              Run terraform apply only (skip destroy)
    --destroy-only            Run terraform destroy only (skip apply)
    --dry-run                 Validate prerequisites without running Terraform
    --include <example,...>   Run only the specified examples
    --exclude <example,...>   Skip the specified examples
    --stop-on-failure         Stop after the first failed example
    --cluster-prefix <pfx>   Prefix for generated cluster names (default: "test")
    --help                    Show this help message

Available examples:
$(printf '    - %s\n' "${ALL_EXAMPLES[@]}")

Environment variables:
    RHCS_TOKEN                OpenShift Cluster Manager API token
    AWS credentials           Credentials/profile for the primary AWS account

Shared VPC only:
    TF_VAR_shared_vpc_aws_access_key_id + TF_VAR_shared_vpc_aws_secret_access_key
      OR TF_VAR_shared_vpc_aws_profile

Examples:
    # Run all Classic examples except shared VPC
    ./run-all-examples.sh --exclude rosa-classic-public-with-shared-vpc

    # Check prerequisites without running Terraform
    ./run-all-examples.sh --exclude rosa-classic-public-with-shared-vpc --dry-run
EOF
}

declare -a INCLUDE_LIST=()
declare -a EXCLUDE_LIST=()
OPTION_ARG=""
DRY_RUN=false
STOP_ON_FAILURE=false
CLUSTER_PREFIX="test"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply-only|--destroy-only)
            if [[ -n "$OPTION_ARG" ]]; then
                echo -e "${RED}Error: --apply-only and --destroy-only are mutually exclusive${NC}"
                exit 1
            fi
            OPTION_ARG="$1"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --include|--exclude|--cluster-prefix)
            if [[ $# -lt 2 || -z "$2" ]]; then
                echo -e "${RED}Error: $1 requires a value${NC}"
                exit 1
            fi
            case "$1" in
                --include) IFS=',' read -ra INCLUDE_LIST <<< "$2" ;;
                --exclude) IFS=',' read -ra EXCLUDE_LIST <<< "$2" ;;
                --cluster-prefix) CLUSTER_PREFIX="$2" ;;
            esac
            shift 2
            ;;
        --stop-on-failure)
            STOP_ON_FAILURE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            usage
            exit 1
            ;;
    esac
done

declare -a EXAMPLES_TO_RUN=()

if [[ ${#INCLUDE_LIST[@]} -gt 0 ]]; then
    for example in "${INCLUDE_LIST[@]}"; do
        if [[ ! -d "${EXAMPLES_DIR}/${example}" ]]; then
            echo -e "${RED}Error: Example '${example}' does not exist${NC}"
            exit 1
        fi
        EXAMPLES_TO_RUN+=("${example}")
    done
else
    EXAMPLES_TO_RUN=("${ALL_EXAMPLES[@]}")
fi

if [[ ${#EXCLUDE_LIST[@]} -gt 0 ]]; then
    declare -a FILTERED=()
    for example in "${EXAMPLES_TO_RUN[@]}"; do
        excluded=false
        for excluded_example in "${EXCLUDE_LIST[@]}"; do
            if [[ "$example" == "$excluded_example" ]]; then
                excluded=true
                break
            fi
        done
        [[ "$excluded" == false ]] && FILTERED+=("${example}")
    done
    EXAMPLES_TO_RUN=("${FILTERED[@]}")
fi

if [[ ${#EXAMPLES_TO_RUN[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No examples to run after filtering${NC}"
    exit 1
fi

short_name() {
    case "$1" in
        ocm-role) echo "ocm" ;;
        rosa-classic-private-with-autoscaler-unmanaged-oidc-byo-vpc) echo "priv-auto" ;;
        rosa-classic-public-with-byo-vpc-byo-iam-byo-oidc) echo "pub-byo" ;;
        rosa-classic-public-with-byo-vpc) echo "pub-vpc" ;;
        rosa-classic-public-with-idp-machine-pools) echo "pub-idp" ;;
        rosa-classic-public-with-multiple-machinepools-and-idps) echo "pub-multi" ;;
        rosa-classic-public-with-shared-vpc) echo "pub-svpc" ;;
        rosa-classic-public-with-unmanaged-oidc) echo "pub-oidc" ;;
        rosa-classic-public) echo "pub" ;;
        *) echo "${1:0:10}" ;;
    esac
}

validate_example() {
    local example="$1"
    local errors=0

    echo -e "  ${CYAN}Checking: ${example}${NC}"

    if [[ -z "${RHCS_TOKEN:-}" ]]; then
        echo -e "    ${RED}MISSING: RHCS_TOKEN${NC}"
        ((errors += 1))
    else
        echo -e "    ${GREEN}OK: RHCS_TOKEN${NC}"
    fi

    if aws sts get-caller-identity &>/dev/null; then
        echo -e "    ${GREEN}OK: primary AWS credentials${NC}"
    else
        echo -e "    ${RED}MISSING: primary AWS credentials (aws sts get-caller-identity failed)${NC}"
        ((errors += 1))
    fi

    if [[ "$example" == *"shared-vpc"* ]]; then
        if [[ -n "${TF_VAR_shared_vpc_aws_access_key_id:-}" && -n "${TF_VAR_shared_vpc_aws_secret_access_key:-}" ]] ||
           [[ -n "${TF_VAR_shared_vpc_aws_profile:-}" ]]; then
            echo -e "    ${GREEN}OK: shared-VPC AWS credentials${NC}"
        else
            echo -e "    ${RED}MISSING: shared-VPC AWS credentials${NC}"
            echo -e "    ${YELLOW}Set the shared-VPC access/secret key pair or TF_VAR_shared_vpc_aws_profile${NC}"
            ((errors += 1))
        fi
    fi

    return "$errors"
}

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  ROSA Classic Examples Runner${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "${CYAN}Examples to run (${#EXAMPLES_TO_RUN[@]}):${NC}"
for example in "${EXAMPLES_TO_RUN[@]}"; do
    if [[ "$example" == "ocm-role" ]]; then
        echo -e "  - ${example} ${YELLOW}(IAM role only, no cluster)${NC}"
    elif [[ "$example" == *"shared-vpc"* ]]; then
        echo -e "  - ${example} ${YELLOW}(requires a second AWS account)${NC}"
    else
        echo -e "  - ${example} ${YELLOW}(cluster: ${CLUSTER_PREFIX}-$(short_name "$example"))${NC}"
    fi
done
echo ""
echo -e "${CYAN}Mode: ${OPTION_ARG:-apply + destroy}${NC}"
echo ""

echo -e "${BOLD}Validating prerequisites...${NC}"
declare -a SKIPPED_EXAMPLES=()
for example in "${EXAMPLES_TO_RUN[@]}"; do
    if ! validate_example "$example"; then
        if [[ "$DRY_RUN" == true || "$STOP_ON_FAILURE" == true ]]; then
            echo -e "${RED}Prerequisite validation failed for '${example}'.${NC}"
            exit 1
        fi
        echo -e "  ${YELLOW}WARNING: Skipping '${example}' due to missing prerequisites${NC}"
        SKIPPED_EXAMPLES+=("${example}")
    fi
done

if [[ ${#SKIPPED_EXAMPLES[@]} -gt 0 ]]; then
    declare -a VALID_EXAMPLES=()
    for example in "${EXAMPLES_TO_RUN[@]}"; do
        skip=false
        for skipped in "${SKIPPED_EXAMPLES[@]}"; do
            [[ "$example" == "$skipped" ]] && skip=true && break
        done
        [[ "$skip" == false ]] && VALID_EXAMPLES+=("${example}")
    done
    EXAMPLES_TO_RUN=("${VALID_EXAMPLES[@]}")
fi

if [[ ${#EXAMPLES_TO_RUN[@]} -eq 0 ]]; then
    echo -e "${RED}No examples remain after prerequisite validation${NC}"
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${GREEN}Dry run complete. Prerequisites validated for ${#EXAMPLES_TO_RUN[@]} example(s).${NC}"
    exit 0
fi

declare -A RESULTS=()
total=${#EXAMPLES_TO_RUN[@]}
current=0

for example in "${EXAMPLES_TO_RUN[@]}"; do
    (( ++current ))
    echo ""
    echo -e "${BOLD}========================================${NC}"
    echo -e "${BOLD}  [${current}/${total}] Running: ${example}${NC}"
    echo -e "${BOLD}========================================${NC}"

    cluster_name="${CLUSTER_PREFIX}-$(short_name "$example")"
    export TF_VAR_cluster_name="${cluster_name}"
    start_time=$(date +%s)

    set +e
    if [[ -n "$OPTION_ARG" ]]; then
        (cd "${REPO_ROOT}" && "${RUN_EXAMPLE}" "${example}" "$OPTION_ARG")
    else
        (cd "${REPO_ROOT}" && "${RUN_EXAMPLE}" "${example}")
    fi
    exit_code=$?
    set -e

    duration=$(( $(date +%s) - start_time ))
    duration_min=$((duration / 60))
    duration_sec=$((duration % 60))
    if [[ $exit_code -eq 0 ]]; then
        RESULTS["$example"]="PASS (${duration_min}m ${duration_sec}s)"
        echo -e "${GREEN}[${current}/${total}] ${example}: PASSED (${duration_min}m ${duration_sec}s)${NC}"
    else
        RESULTS["$example"]="FAIL (exit ${exit_code}, ${duration_min}m ${duration_sec}s)"
        echo -e "${RED}[${current}/${total}] ${example}: FAILED (exit ${exit_code}, ${duration_min}m ${duration_sec}s)${NC}"
        [[ "$STOP_ON_FAILURE" == true ]] && break
    fi
done

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  Results Summary${NC}"
echo -e "${BOLD}========================================${NC}"
pass_count=0
fail_count=0
for example in "${EXAMPLES_TO_RUN[@]}"; do
    result="${RESULTS[$example]:-SKIPPED}"
    case "$result" in
        PASS*) echo -e "  ${GREEN}PASS${NC}  ${example}  ${YELLOW}${result#PASS }${NC}"; ((pass_count += 1)) ;;
        FAIL*) echo -e "  ${RED}FAIL${NC}  ${example}  ${YELLOW}${result#FAIL }${NC}"; ((fail_count += 1)) ;;
        SKIPPED) echo -e "  ${YELLOW}SKIP${NC}  ${example}" ;;
    esac
done
echo ""
echo -e "${BOLD}Total: ${pass_count} passed, ${fail_count} failed${NC}"
[[ $fail_count -gt 0 ]] && exit 1
