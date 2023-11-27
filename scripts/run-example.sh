#!/bin/bash

set -e

function runexample::usage() {
	echo "Usage:

	./run-example.sh <example_name>
	"
}

if (( "$#" < 1 )); then
	echo "Error:
	Unsupported command!!!
	"
        runexample::usage
	exit 1
fi

##############################################################
# Change directory to example directory given in arg $1
##############################################################

EXAMPLE_NAME=$1
shift
REPO_ROOT_DIR="$( cd -- "$(dirname "$1")" >/dev/null 2>&1 ; pwd -P )"
EXAMPLE_PATH="${REPO_ROOT_DIR}/examples/${EXAMPLE_NAME}"
if [ ! -d "${EXAMPLE_PATH}" ]; then
	echo "Error:
	Example \"${EXAMPLE_NAME}\" does not exist!!!
  Full path: \"${EXAMPLE_PATH}\"
	"
  exit 1
fi

echo "Running example \"${EXAMPLE_NAME}\" - changing directory to \"${EXAMPLE_PATH}\""
cd ${EXAMPLE_PATH}

##############################################################
# Validate environment variables
##############################################################

if [[ -z "${RHCS_TOKEN}" ]]; then
	echo "Error:
	\"RHCS_TOKEN\" environment variable is not defined!!!
	"
  exit 1
fi

if [[ -z "${RHCS_EXAMPLE_CLUSTER_NAME}" ]]; then
	echo "Error:
	\"RHCS_EXAMPLE_CLUSTER_NAME\" environment variable is not defined!!!
	"
  exit 1
fi

##############################################################
# Execute terraform apply command
##############################################################

echo "Running \"terraform init\" ..."
terraform init
echo "\"terraform init\" completed"

set +e

echo "Running \"terraform apply\" ..."
terraform apply -var="cluster_name=${RHCS_EXAMPLE_CLUSTER_NAME}" -auto-approve || _apply_failed=true
if [ $_apply_failed ]
then
    echo "\"terraform apply\" failed"
else
    echo "\"terraform apply\" completed"
fi

set -e

echo "Running \"terraform destroy\" ..."
terraform destroy -var="cluster_name=${RHCS_EXAMPLE_CLUSTER_NAME}" -auto-approve
echo "\"terraform destroy\" completed"

if [ $_apply_failed ]
then
	echo "Error:
	terraform apply was failed!!!
	"
  exit 2
fi
