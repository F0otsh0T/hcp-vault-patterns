################################################################################
# VAULT PKI CLI - PKI ENGINE & ROOT CA
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
all: pki-enable pki-ca_root_create pki-ca_crl #target ## All Targets

##########
# ENABLE VAULT PKI SECRETS ENGINE
#
.PHONY: pki-enable
pki-enable: #target ## Secrets Enable PKI
	vault secrets enable pki
	vault secrets tune -max-lease-ttl=87600h pki

##########
# CREATE INTERNAL CA ROOT CERTIFICATE
#
.PHONY: pki-ca_root_create
pki-ca_root_create: #target ## Create CA Root
	vault write -format=json pki/root/generate/internal common_name="y0y0dyn3.com" ttl=87600h | jq > workspace/tmp/ca_root.json
	cat workspace/tmp/ca_root.json | jq -r '.data.certificate' > workspace/tmp/CA_cert.crt
	cat workspace/tmp/ca_root.json | jq -r '.data.certificate' > workspace/tmp/ca_root.certificate
	cat workspace/tmp/ca_root.json | jq -r '.data.serial_number' > workspace/tmp/ca_root.serial_number
	cat workspace/tmp/ca_root.json | jq -r '.data.issuing_ca' > workspace/tmp/ca_root.issuing_ca

##########
# CONFIGURE CA and CRL PUBLISH URLs (Substitute 127.0.0.1:8200 with your Vault Service URL)
#
.PHONY: pki-ca_crl
pki-ca_crl: #target ## Configure CA and CRUL Publish URLs
#	vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
#	vault write pki/config/urls issuing_certificates="https://vault-cluster.vault.f039419a-9b9b-47e2-9cae-7462d5a0c29b.aws.hashicorp.cloud:8200/v1/pki/ca" crl_distribution_points="https://vault-cluster.vault.f039419a-9b9b-47e2-9cae-7462d5a0c29b.aws.hashicorp.cloud:8200/v1/pki/crl"
	vault write pki/config/urls issuing_certificates="${VAULT_ADDR}/v1/pki/ca" crl_distribution_points="${VAULT_ADDR}/v1/pki/crl"

##########
# LIST CERTS
#
.PHONY: cert-list
cert-list: #target ## List Certs
	vault list -format=json pki/certs | jq
	vault list -format=json pki_int/certs | jq

##########
# READ CERT
#
.PHONY: cert-read
cert-read: #target ## Read Cert
	vault read -format=json pki/cert/$(shell cat workspace/tmp/ca_root.serial_number) | jq

################################################################################

##########
# DISABLE PKI ENGINE PKI
#
.PHONY: pki-disable
pki-disable: #target ## Secrets Disable PKI
	vault secrets disable pki

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






