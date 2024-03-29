################################################################################
# VAULT PKI CLI - PKI_INT ENGINE & INTERMEDIATE CA
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
.PHONY: help all pki_int-enable pki_int-csr pki_int-csr_sign pki_int-cert_import pki_int-ca_crl pki_int-role_create

################################################################################
# ALL
################################################################################
all: pki_int-enable pki_int-csr pki_int-csr_sign pki_int-cert_import pki_int-ca_crl pki_int-role_create #target ## All Targets

##########
# ENABLE PKI ENGINE - PKI_INT
#
pki_int-enable: #target ## Secrets Enable PKI INT
	vault secrets enable -path=pki_int pki
	vault secrets tune -max-lease-ttl=43800h pki_int

##########
# GENERATE INTERMEDIATE CSR FROM PKI_INT ENGINE
#
pki_int-csr: #target ## Generate Intermediate CSR
	vault write -format=json pki_int/intermediate/generate/internal common_name="y0y0dyn3.com Intermediate Authority" | jq > workspace/tmp/pki_int.json
	cat workspace/tmp/pki_int.json | jq -r '.data.csr' > workspace/tmp/pki_int.csr
	cat workspace/tmp/pki_int.csr

##########
# SIGN INTERMEDIATE CSR WITH CA ROOT IN PKI ENGINE & OUTPUT INTERMEDIATE CA (PEM)
#
pki_int-csr_sign: #target ## Sign Intermediate CSR
	vault write -format=json pki/root/sign-intermediate csr=@workspace/tmp/pki_int.csr format=pem_bundle ttl="43800h" | jq > workspace/tmp/pki_int.cert.json
	cat workspace/tmp/pki_int.cert.json | jq -r '.data.certificate' > workspace/tmp/pki_int.cert.pem

##########
# IMPORT & PUBLISH CA ROOT SIGNED INTERMEDIATE CERTIFICATE BACK INTO PKI_INT ENGINE
#
pki_int-cert_import: #target ## Import and Publish Signed CSR
	vault write pki_int/intermediate/set-signed certificate=@workspace/tmp/pki_int.cert.pem

##########
# CONFIGURE CA and CRL PUBLISH URLs (Substitute 127.0.0.1:8200 with your Vault Service URL)
#
pki_int-ca_crl: #target ## Configure CA and CRL Publish URLs
#	vault write pki_int/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki_int/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki_int/crl"
#	vault write pki_int/config/urls issuing_certificates="https://vault-cluster.vault..aws.hashicorp.cloud:8200/v1/pki_int/ca" crl_distribution_points="https://vault-cluster.vault.f039419a-9b9b-47e2-9cae-7462d5a0c29b.aws.hashicorp.cloud:8200/v1/pki_int/crl"
	vault write pki_int/config/urls issuing_certificates="${VAULT_ADDR}/v1/pki_int/ca" crl_distribution_points="${VAULT_ADDR}/v1/pki_int/crl"
#	VAULT_ADDR=${VAULT_ADDR}
#	echo ${VAULT_ADDR}

################################################################################

##########
# CREATE PKI_INT ENGINE ROLE FOR CN / CERTIFICATE GENERATION
#
pki_int-role_create: #target ## Create PKI INT Engine Role
	vault write pki_int/roles/y0y0dyn3-dot-com allowed_domains="y0y0dyn3.com" allow_subdomains=true max_ttl="720h"

################################################################################

##########
# LIST CERTS
#
cert-list: #target ## List Certs
	vault list -format=json pki/certs | jq
	vault list -format=json pki_int/certs | jq

##########
# READ CERT
#
cert-read: #target ## Read Certs
	vault read -format=json pki/cert/$(shell jq -r .data.serial_number < workspace/tmp/pki_int.cert.json) | jq
#	vault read -format=json pki/cert/$(shell cat workspace/tmp/pki_int.cert.pem) | jq

################################################################################

##########
# DISABLE PKI ENGINE PKI_INT
#
pki_int-disable: #target ## Disable Secret PKI INT
	vault secrets disable pki_int

################################
# HELP
# REF GH @ jen20/hashidays-nyc/blob/master/terraform/GNUmakefile
################################
help: #target ## [DEFAULT] Display help for this Makefile.
	@echo "Valid make targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check_defined = \
		$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
		$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))