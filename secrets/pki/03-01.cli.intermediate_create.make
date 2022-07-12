################################################################################
# VAULT PKI CLI - PKI_INT CREATE & PROCESS INTERMEDIATE CERTIFICATE
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
.PHONY: 
all: cert-create cert-format cert-list cert-read #target ## All Targets

##########
# GENERATE INTERMEDIATE CERTIFICATE FOR ROLE CN
#
.PHONY: cert-create
cert-create: #target ## Generate Intermediate Cert
#	vault write pki_int/issue/y0y0dyn3-dot-com common_name="test.y0y0dyn3.com" ttl="24h" -format=json | jq > workspace/tmp/intermediate.json
	vault write pki_int/issue/y0y0dyn3-dot-com common_name="test.y0y0dyn3.com" ttl="1h" -format=json | jq > workspace/tmp/intermediate.json

##########
# FORMAT INTERMEDIATE CERTIFICATE FOR CLIENT CONSUMPTION
#
.PHONY: cert-format
cert-format: #target ## Format Cert
	touch workspace/tmp/server.bundle
	cat workspace/tmp/intermediate.json | jq -r '.data.certificate' > workspace/tmp/server.certificate
	cat workspace/tmp/intermediate.json | jq -r '.data.private_key' > workspace/tmp/server.private_key
	cat workspace/tmp/intermediate.json | jq -r '.data.issuing_ca' > workspace/tmp/server.issuing_ca
	cat workspace/tmp/intermediate.json | jq -r '.data.serial_number' > workspace/tmp/server.serial_number
	cp workspace/tmp/server.bundle workspace/tmp/server.bundle.$(shell date +"%Y%m%d-%H%M%S").bak
#	cat workspace/tmp/server.certificate workspace/tmp/server.private_key workspace/tmp/server.issuing_ca > workspace/tmp/server.bundle
#	cat workspace/tmp/server.certificate workspace/tmp/server.issuing_ca > workspace/tmp/server.bundle
	cat workspace/tmp/server.certificate workspace/tmp/server.issuing_ca workspace/tmp/ca_root.issuing_ca > workspace/tmp/server.bundle

##########
# LIST CERTS
#
.PHONY: cert-list
cert-list: #target ## List Cert
	vault list -format=json pki/certs | jq
	vault list -format=json pki_int/certs | jq

##########
# READ CERT
#
.PHONY: cert-read
cert-read: #target ## Read Cert
	vault read -format=json pki_int/cert/$(shell cat workspace/tmp/server.serial_number) | jq

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


