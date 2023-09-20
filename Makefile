# Define a variable for the Terraform examples directory
TERRAFORM_DIR := examples/rosa-classic-with-unmanaged-oidc

verify:
	@cd $(TERRAFORM_DIR) && terraform validate

tests:
	sh tests.sh
