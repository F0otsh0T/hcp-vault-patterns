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
all: build terraform-init terraform-apply verify #target ## All Targets

##########
# CLEAN
#
.PHONY: clean
clean: #target ## Clean Up
	terraform destroy -auto-approve

##########
# CERT - BUNDLE
#
.PHONY: cert-bundle
cert-bundle: #target ## Bundle Certs
	cat tmp/bob/intermediate.json | jq -r '.data.certificate' > tmp/bob/server.certificate
	cat tmp/bob/intermediate.json | jq -r '.data.private_key' > tmp/bob/server.private_key
	cat tmp/bob/intermediate.json | jq -r '.data.issuing_ca' > tmp/bob/server.issuing_ca
	cat tmp/bob/intermediate.json | jq -r '.data.serial_number' > tmp/bob/server.serial_number
	cp tmp/bob/server.bundle tmp/bob/server.bundle.$(shell date +"%Y%m%d-%H%M%S").bak
#	cat tmp/bob/server.certificate tmp/bob/server.private_key tmp/bob/server.issuing_ca > tmp/bob/server.bundle
#	cat tmp/bob/server.certificate tmp/bob/server.issuing_ca > tmp/bob/server.bundle
	cat tmp/bob/server.certificate tmp/bob/server.issuing_ca tmp/bob/ca_root.issuing_ca > tmp/bob/server.bundle

##########
# BUILD CLIENT IMAGE
#
.PHONY: build
build: #target ## Build Client Container Image
	docker build -t mtlsserver:0.1 -f ./bob.Dockerfile .
	docker image tag mtlsserver:0.1 mtlsserver:latest
	docker build -t mtlsclient:0.1 -f ./alice.Dockerfile .
	docker image tag mtlsclient:0.1 mtlsclient:latest

##########
# TERRAFORM INIT
#
.PHONY: terraform-init
terraform-init: #target ## Terraform Init
	terraform init

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
# VERIFY MTLS
#
.PHONY: verify
verify: #target ## Verify mTLS Server Client
	docker exec -it mtlsclient curl -k \
		--url     https://192.168.65.2:9002 \
		--cert    /vault/secrets/client.certificate \
		--key     /vault/secrets/client.private_key \
		--cacert  /vault/secrets/ca_root.issuing_ca \
		--verbose

##########
# TEST CLIENT IMAGE
#
.PHONY: test
test: #target ## Test Client Container Image
#	docker run -it -e VAULT_TOKEN=$(pass vault/pki_test) --privileged -p 9001:80 -p 9002:443 --name pkiclient pkiclient:0.1 bash
	docker stop testnginx-server testnginx-client
	docker rm testnginx-server testnginx-client
	docker run -it --privileged -p 9001:80  -p 9002:443 --name testnginx-server mtlsserver:latest uname -a
	docker run -it --privileged -p 9003:80  -p 9004:443 --name testnginx-client mtlsclient:latest uname -a
#	docker rm testnginx

##########
# RUN CLIENT IMAGE
#
run: #target
	docker run -d --privileged -p 9001:80 -p 9002:443 --name testnginx-server mtlsserver:latest
	docker run -d --priveleged -p 9003:80 -p 9004:443 --name testnginx-client mtlsclient:latest

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
