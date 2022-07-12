################################################################################
# VAULT PKI CLI - PKI_INT REVOKE & TIDY INTERMEDIATE CERTIFICATE
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
all: cert-revoke cert-tidy #target ## All Targets

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

##########
# REVOKE INTERMEDIATE CERTIFICATE
#
.PHONY: cert-revoke
cert-revoke: #target ## Revoke Intermediate Certificate
	touch workspace/tmp/cert-revoke.json
	cp workspace/tmp/cert-revoke.json workspace/tmp/cert.revoke.json.$(shell date +"%Y%m%d-%H%M%S")
#	echo '{ "serial_number": "$(shell cat workspace/tmp/server.serial_number)" }' > workspace/tmp/cert-revoke.json
	vault write -format=json pki_int/revoke serial_number=$(shell cat workspace/tmp/server.serial_number) | jq > workspace/tmp/revoke.out

##########
# CERTIFICATE TIDY
#
.PHONY: cert-tidy
cert-tidy: #target # Certificate Tidy
	vault write -format=json pki_int/tidy safety_buffer=5s tidy_cert_store=true tidy_revocation_list=true | jq > workspace/tmp/tidy.out

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

