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
	vault secrets enable -path=pki_int-bob pki
	vault secrets tune -max-lease-ttl=43800h pki_int-bob

##########
# GENERATE INTERMEDIATE CSR FROM PKI_INT ENGINE
#
pki_int-csr: #target ## Generate Intermediate CSR
	vault write -format=json pki_int-bob/intermediate/generate/internal common_name="5gc.mnc88.mcc888.3gppnetwork.org Intermediate Authority" | jq > workspace/tmp/bob/pki_int-bob.json
	cat workspace/tmp/bob/pki_int-bob.json | jq -r '.data.csr' > workspace/tmp/bob/pki_int-bob.csr
	cat workspace/tmp/bob/pki_int-bob.csr

##########
# SIGN INTERMEDIATE CSR WITH CA ROOT IN PKI ENGINE & OUTPUT INTERMEDIATE CA (PEM)
#
pki_int-csr_sign: #target ## Sign Intermediate CSR
	vault write -format=json pki-bob/root/sign-intermediate csr=@workspace/tmp/bob/pki_int-bob.csr format=pem_bundle ttl="43800h" | jq > workspace/tmp/bob/pki_int-bob.cert.json
	cat workspace/tmp/bob/pki_int-bob.cert.json | jq -r '.data.certificate' > workspace/tmp/bob/pki_int-bob.cert.pem

##########
# IMPORT & PUBLISH CA ROOT SIGNED INTERMEDIATE CERTIFICATE BACK INTO PKI_INT ENGINE
#
pki_int-cert_import: #target ## Import and Publish Signed CSR
	vault write pki_int-bob/intermediate/set-signed certificate=@workspace/tmp/bob/pki_int-bob.cert.pem

##########
# CONFIGURE CA and CRL PUBLISH URLs (Substitute 127.0.0.1:8200 with your Vault Service URL)
#
pki_int-ca_crl: #target ## Configure CA and CRL Publish URLs
#	VAULT_ADDR=${VAULT_ADDR}
#	echo ${VAULT_ADDR}
	## Comment out below two lines export if you do not need to manually enter host.docker.internal for your Testbed
	## These URLs need to be reachable from your PKI Consumers
#	export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
	vault write pki_int-bob/config/urls issuing_certificates="http://192.168.65.2:18200/v1/pki_int-bob/ca" crl_distribution_points="http://192.168.65.2:18200/v1/pki_int-bob/crl"
#	vault write pki_int-bob/config/urls issuing_certificates="${VAULT_ADDR}/v1/pki_int-bob/ca" crl_distribution_points="${VAULT_ADDR}/v1/pki_int-bob/crl"


################################################################################

##########
# CREATE PKI_INT ENGINE ROLE FOR CN / CERTIFICATE GENERATION
#
pki_int-role_create: #target ## Create PKI INT Engine Role
#	vault write pki_int-bob/roles/bob-server allowed_domains="5gc.mnc88.mcc888.3gppnetwork.org" allow_subdomains=true max_ttl="720h"
# Create mTLS Server Role
	vault write pki_int-bob/roles/bob-server \
		max_ttl="720h" \
		add_basic_constraints=true \
		server_flag=true \
		client_flag=false \
		allow_glob_domains=true \
		allowed_domains="*.5gc.mnc88.mcc888.3gppnetwork.org" \
		allowed_subdomains=true \
		organization="5gc.mnc88.mcc888.3gppnetwork.org" \
		key_usage="DigitalSignature,KeyEncipherment" \
		alt_names="*.5gc.mnc88.mcc888.3gppnetwork.org" \
		allowed_uri_sans="*.5gc.mnc88.mcc888.3gppnetwork.org" \
		uri_sans="*.5gc.mnc88.mcc888.3gppnetwork.org"
# Create mTLS Client Role
	vault write pki_int-bob/roles/bob-client-alice \
		max_ttl="720h" \
		add_basic_constraints=true \
		server_flag=false \
		client_flag=true \
		allow_glob_domains=true \
		allowed_domains="*.5gc.mnc88.mcc888.3gppnetwork.org" \
		allowed_subdomains=true \
		organization="5gc.mnc88.mcc888.3gppnetwork.org" \
		key_usage="DigitalSignature" \
		alt_names="*.5gc.mnc88.mcc888.3gppnetwork.org" \
		allowed_uri_sans="*.5gc.mnc88.mcc888.3gppnetwork.org" \
		uri_sans="*.5gc.mnc88.mcc888.3gppnetwork.org"

################################################################################

##########
# LIST CERTS
#
cert-list: #target ## List Certs
	vault list -format=json pki-bob/certs | jq
	vault list -format=json pki_int-bob/certs | jq

##########
# READ CERT
#
cert-read: #target ## Read Certs
	vault read -format=json pki-bob/cert/$(shell jq -r .data.serial_number < workspace/tmp/bob/pki_int-bob.cert.json) | jq
#	vault read -format=json pki-bob/cert/$(shell cat workspace/tmp/bob/pki_int-bob.cert.pem) | jq

################################################################################

##########
# DISABLE PKI ENGINE PKI_INT
#
pki_int-disable: #target ## Disable Secret PKI INT
	vault secrets disable pki_int-bob

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