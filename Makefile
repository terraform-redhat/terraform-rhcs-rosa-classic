# Define a variable for the Terraform examples directory
TERRAFORM_DIR := examples/rosa-classic-with-unmanaged-oidc

verify:
	@cd $(TERRAFORM_DIR) && terraform validate

tests:
	sh tests.sh

dev-environment:
	find . -type f -name "versions.tf" -exec sed -i -e "s/terraform-redhat\/rhcs/terraform.local\/local\/rhcs/g" -- {} +

registry-environment:
	find . -type f -name "versions.tf" -exec sed -i -e "s/terraform.local\/local\/rhcs/terraform-redhat\/rhcs/g" -- {} +

run-example:
	sh scripts/run-example.sh
