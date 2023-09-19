# Define a variable for the Terraform examples directory
TERRAFORM_DIR := examples/rosa-classic-with-unmanaged-oidc

init:
	@cd $(TERRAFORM_DIR) && terraform init

verify:
	@cd $(TERRAFORM_DIR) && terraform validate

tests:
	sh tests.sh

destroy:
	@cd $(TERRAFORM_DIR) && terraform destroy

