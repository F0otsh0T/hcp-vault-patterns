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
all: build terraform-init terraform-apply #target ## All Targets

##########
# CLEAN
#
.PHONY: clean
clean: #target ## Clean Up
	terraform init
	terraform destroy -auto-approve

##########
# BUILD CLIENT IMAGE
#
.PHONY: build
build: #target ## Build Client Container Image
#	# AMF
	docker build -t mtlsxamf:0.1 -f ./tmp/amf/amf.Containerfile .
	docker image tag mtlsxamf:0.1 mtlsxamf:latest
#	# NEF
	docker build -t mtlsxnef:0.1 -f ./tmp/nef/nef.Containerfile .
	docker image tag mtlsxnef:0.1 mtlsxnef:latest
#	# PCF
	docker build -t mtlsxsmf:0.1 -f ./tmp/smf/smf.Containerfile .
	docker image tag mtlsxsmf:0.1 mtlsxsmf:latest
#	#SMF
	docker build -t mtlsxpcf:0.1 -f ./tmp/pcf/pcf.Containerfile .
	docker image tag mtlsxpcf:0.1 mtlsxpcf:latest

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
	docker exec -it mtlsxsmf curl -k \
		--url     https://192.168.65.2:9006 \
		--cert    /vault/secrets/alice/n7-client.certificate \
		--key     /vault/secrets/alice/n7-client.private_key \
		--cacert  /vault/secrets/alice/ca/ca_root.certificate \
		-vvv

##########
# TEST CLIENT IMAGE
#
.PHONY: test
test: #target ## Test Client Container Image
#	docker run -it -e VAULT_TOKEN=$(pass vault/pki_test) --privileged -p 9001:80 -p 9002:443 --name pkiclient pkiclient:0.1 bash
	docker stop testnginx-server testnginx-client
	docker rm testnginx-server testnginx-client
	docker run -it --privileged -p 9005:80  -p 9006:443 --name testnginx-pcf mtlsxpcf:latest uname -a
	docker run -it --privileged -p 9007:80  -p 9008:443 --name testnginx-smf mtlsxsmf:latest uname -a
	docker run -it --privileged -p 9007:80  -p 9008:443 --name testnginx-amf mtlsxsmf:latest uname -a
#	docker rm testnginx

##########
# RUN CLIENT IMAGE
#
run: #target
	docker run -d --privileged -p 9001:80 -p 9002:443 --name testnginx-pcf mtlsxpcf:latest
	docker run -d --priveleged -p 9003:80 -p 9004:443 --name testnginx-smf mtlsxsmf:latest
	docker run -d --priveleged -p 9003:80 -p 9004:443 --name testnginx-amf mtlsxamf:latest

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
