######################
# Define a variable for the Terraform examples directory
# TERRAFORM_DIR := examples/rosa-classic-public
# TERRAFORM_DIR := examples/rosa-classic-public-with-byo-vpc
# TERRAFORM_DIR := examples/rosa-classic-public-with-byo-vpc-byo-iam-byo-oidc
TERRAFORM_DIR := examples/rosa-classic-public-with-idp-machine-pools
# TERRAFORM_DIR := examples/rosa-classic-public-with-unmanaged-oidc

######################
# Log into your AWS account before running this make file.
# Create .env file with your ROSA token. This file will be ignored by git.
# format.
# RHCS_TOKEN=<ROSA TOKEN>

# include .env
# export $(shell sed '/^\#/d; s/=.*//' .env)
TF_LOG=INFO
######################
# .EXPORT_ALL_VARIABLES:

# Run make init \ make plan \ make apply \ make destroy

.PHONY: verify
# This target is used by prow target (https://github.com/openshift/release/blob/77159f7696ed6c7bae518091079724cb8217dd33/ci-operator/config/terraform-redhat/terraform-rhcs-rosa/terraform-redhat-terraform-rhcs-rosa-main.yaml#L18)
# Don't remove this target
verify:
	@for d in examples/*; do \
		echo "!! Validating $$d !!" && cd $$d && terraform init && terraform validate && cd - ;\
	done

.PHONY: tf-init
tf-init:
	@cd $(TERRAFORM_DIR) && terraform init -input=false -lock=false -no-color -reconfigure

.PHONY: tf-plan
tf-plan: format validate
	@cd $(TERRAFORM_DIR) && terraform plan -lock=false -out=.terraform-plan

.PHONY: tf-apply
tf-apply:
	@cd $(TERRAFORM_DIR) && terraform apply .terraform-plan

.PHONY: tf-destroy
tf-destroy:
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve -input=false

.PHONY: tf-output
tf-output:
	@cd $(TERRAFORM_DIR) && terraform output > tf-output-parameters

.PHONY: tf-format
tf-format:
	@cd $(TERRAFORM_DIR) && terraform fmt

.PHONY: tf-validate
tf-validate:
	@cd $(TERRAFORM_DIR) && terraform validate

.PHONY: tests
tests:
	sh tests.sh

.PHONY: dev-environment
dev-environment:
	find . -type f -name "versions.tf" -exec sed -i -e "s/terraform-redhat\/rhcs/terraform.local\/local\/rhcs/g" -- {} +

.PHONY: registry-environment
registry-environment:
	find . -type f -name "versions.tf" -exec sed -i -e "s/terraform.local\/local\/rhcs/terraform-redhat\/rhcs/g" -- {} +
