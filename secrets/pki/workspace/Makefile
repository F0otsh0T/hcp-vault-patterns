################################################################################
# VAULT POC CLIENT NGINX - BUILD CONTAINER IMAGE
# "TAO // IMMUTABLE"
#
# @file
# @version 0.1
#
##########
# PREREQUISITES
#   - Docker
#   - Kind
#   - kubectl
#   - Vault CLI
#   - Terraform
#   - make
#   - jq
#   - curl
#   - PGP/GPG/PASS
#   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,
################################################################################

################################
# DEFAULTS
################################
default: help

################################################################################
# ALL
################################################################################
.PHONY: all
all: build terraform-apply #target ## All Targets

##########
#
#

##########
# CERT - BUNDLE
#
.PHONY: cert-bundle
cert-bundle: #target ## Bundle Certs
	cat tmp/intermediate.json | jq -r '.data.certificate' > tmp/server.certificate
	cat tmp/intermediate.json | jq -r '.data.private_key' > tmp/server.private_key
	cat tmp/intermediate.json | jq -r '.data.issuing_ca' > tmp/server.issuing_ca
	cat tmp/intermediate.json | jq -r '.data.serial_number' > tmp/server.serial_number
	cp tmp/server.bundle tmp/server.bundle.$(shell date +"%Y%m%d-%H%M%S").bak
#	cat tmp/server.certificate tmp/server.private_key tmp/server.issuing_ca > tmp/server.bundle
#	cat tmp/server.certificate tmp/server.issuing_ca > tmp/server.bundle
	cat tmp/server.certificate tmp/server.issuing_ca tmp/ca_root.issuing_ca > tmp/server.bundle

##########
# BUILD CLIENT IMAGE
#
.PHONY: build
build: #target ## Build Client Container Image
	docker build -t pkiclient:0.1 -f ./Dockerfile .
	docker image tag pkiclient:0.1 pkiclient:latest

##########
# TERRAFORM INIT
#
.PHONY: terraform-init
terraform-init: #target ## Terraform Init
	terraform init -auto-approve

##########
# TERRAFORM PLAN
#
.PHONY: terraform-plan
terraform-plan: #target ## Terraform Plan
	terraform plan -auto-approve

##########
# TERRAFORM APPLY
#
.PHONY: terraform-apply
terraform-apply: #target ## Terraform Apply
	terraform apply -auto-approve

##########
# TERRAFORM REFRESH
#
.PHONY: terraform-refesh
terraform-refesh: #target ## Terraform Refresh
	terraform refresh -auto-approve

##########
# TEST CLIENT IMAGE
#
.PHONY: test
test: #target ## Test Client Container Image
#    docker run -it -e VAULT_TOKEN=$(pass vault/pki_test) --privileged -p 9001:80 -p 9002:443 --name pkiclient pkiclient:0.1 bash
	docker stop testnginx
	docker rm testnginx
	docker run -it --privileged -p 9001:80  -p 9002:443 --name testnginx pkiclient:latest bash
#	docker rm testnginx

##########
# RUN CLIENT IMAGE
#
run: #target
	docker run -d --privileged -p 9001:80 -p 9002:443 --name testnginx pkiclient:latest

################################
# HELP
# REF GH @ jen20/hashidays-nyc/blob/master/terraform/GNUmakefile
################################
.PHONY: help
help: #target ## [DEFAULT] Display help for this Makefile.
	@echo "Valid make targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check_defined = \
		$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
		$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))
