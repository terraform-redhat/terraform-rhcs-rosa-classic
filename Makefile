######################
# Define a variable for the Terraform examples directory
TERRAFORM_DIR := examples/rosa-classic-public
# TERRAFORM_DIR := examples/rosa-classic-public-with-byo-vpc
# TERRAFORM_DIR := examples/rosa-classic-public-with-byo-vpc-byo-iam-byo-oidc
# TERRAFORM_DIR := examples/rosa-classic-public-with-idp-machine-pools
# TERRAFORM_DIR := examples/rosa-classic-public-with-unmanaged-oidc

######################
# Log into your AWS account before running this make file.
# Create .env file with your ROSA token. This file will be ignored by git.
# format.
# RHCS_TOKEN=<ROSA TOKEN>

include .env
export $(shell sed '/^\#/d; s/=.*//' .env)
TF_LOG=INFO
######################
.EXPORT_ALL_VARIABLES:

# Run make init \ make plan \ make apply \ make destroy

init:
	@cd $(TERRAFORM_DIR) && terraform init -input=false -lock=false -no-color -reconfigure
.PHONY: init

plan: format validate
	@cd $(TERRAFORM_DIR) && terraform plan -lock=false -out=.terraform-plan
.PHONY: plan

apply:
	@cd $(TERRAFORM_DIR) && terraform apply .terraform-plan
.PHONY: apply

destroy:
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve -input=false
.PHONY: destroy

output:
	@cd $(TERRAFORM_DIR) && terraform output > tf-output-parameters
.PHONY: output

format:
	@cd $(TERRAFORM_DIR) && terraform fmt

validate:
	@cd $(TERRAFORM_DIR) && terraform validate

tests:
	sh tests.sh

dev-environment:
	find . -type f -name "versions.tf" -exec sed -i -e "s/terraform-redhat\/rhcs/terraform.local\/local\/rhcs/g" -- {} +

registry-environment:
	find . -type f -name "versions.tf" -exec sed -i -e "s/terraform.local\/local\/rhcs/terraform-redhat\/rhcs/g" -- {} +
