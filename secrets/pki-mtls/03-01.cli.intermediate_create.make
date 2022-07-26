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
#	vault write pki_int-bob/issue/bob-server \common_name="bob.5gc.mnc88.mcc888.3gppnetwork.org" ttl="24h" -format=json | jq > workspace/tmp/bob/intermediate-server.json
# Create mTLS Server Certificate
	vault write pki_int-bob/issue/bob-server \
		common_name="bob.5gc.mnc88.mcc888.3gppnetwork.org" \
		alt_names="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
		uri_sans="pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
		ttl="1h" \
		-format=json | jq > workspace/tmp/bob/intermediate-server.json
# Create mTLS Client Certificate
	vault write pki_int-bob/issue/bob-client-alice \
	common_name="alice.5gc.mnc88.mcc888.3gppnetwork.org" \
		alt_names="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
		uri_sans="smf.5gc.mnc88.mcc888.3gppnetwork.org" \
		ttl="1h" \
		-format=json | jq > workspace/tmp/bob/intermediate-client.json

##########
# FORMAT INTERMEDIATE CERTIFICATES
#
.PHONY: cert-format
cert-format: #target ## Format Cert
# Format mTLS Server Certificate
	touch workspace/tmp/bob/server.bundle
	cat workspace/tmp/bob/intermediate-server.json | jq -r '.data.certificate' > workspace/tmp/bob/server.certificate
	cat workspace/tmp/bob/intermediate-server.json | jq -r '.data.private_key' > workspace/tmp/bob/server.private_key
	cat workspace/tmp/bob/intermediate-server.json | jq -r '.data.issuing_ca' > workspace/tmp/bob/server.issuing_ca
	cat workspace/tmp/bob/intermediate-server.json | jq -r '.data.serial_number' > workspace/tmp/bob/server.serial_number
	cp workspace/tmp/bob/server.bundle workspace/tmp/bob/_archive/server.bundle.$(shell date +"%Y%m%d-%H%M%S").bak
#	cat workspace/tmp/bob/server.certificate workspace/tmp/bob/server.private_key workspace/tmp/bob/server.issuing_ca > workspace/tmp/bob/server.bundle
#	cat workspace/tmp/bob/server.certificate workspace/tmp/bob/server.issuing_ca > workspace/tmp/bob/server.bundle
	cat workspace/tmp/bob/server.certificate workspace/tmp/bob/server.issuing_ca workspace/tmp/bob/ca_root.issuing_ca > workspace/tmp/bob/server.bundle
# Format mTLS Client Certificate
	touch workspace/tmp/bob/client.bundle
	cat workspace/tmp/bob/intermediate-client.json | jq -r '.data.certificate' > workspace/tmp/bob/client.certificate
	cat workspace/tmp/bob/intermediate-client.json | jq -r '.data.private_key' > workspace/tmp/bob/client.private_key
	cat workspace/tmp/bob/intermediate-client.json | jq -r '.data.issuing_ca' > workspace/tmp/bob/client.issuing_ca
	cat workspace/tmp/bob/intermediate-client.json | jq -r '.data.serial_number' > workspace/tmp/bob/client.serial_number
	cp workspace/tmp/bob/client.bundle workspace/tmp/bob/_archive/client.bundle.$(shell date +"%Y%m%d-%H%M%S").bak
	cat workspace/tmp/bob/client.certificate workspace/tmp/bob/client.issuing_ca workspace/tmp/bob/ca_root.issuing_ca > workspace/tmp/bob/client.bundle

##########
# LIST CERTS
#
.PHONY: cert-list
cert-list: #target ## List Cert
	vault list -format=json pki-bob/certs | jq
	vault list -format=json pki_int-bob/certs | jq

##########
# READ CERT
#
.PHONY: cert-read
cert-read: #target ## Read Cert
# Read mTLS Server Certificate
	@echo "###########################\n# Read Server Certificate #\n###########################"
	vault read -format=json pki_int-bob/cert/$(shell cat workspace/tmp/bob/server.serial_number) | jq
# Check mTLS Server Certificate
	@echo "############################\n# Check Server Certificate #\n############################"
	openssl x509 -in workspace/tmp/bob/server.certificate -text -noout
# Read mTLS Client Certificate
	@echo "###########################\n# Read Client Certificate #\n###########################"
	vault read -format=json pki_int-bob/cert/$(shell cat workspace/tmp/bob/client.serial_number) | jq
# Check mTLS Client Certificate
	@echo "############################\n# Check Client Certificate #\n############################"
	openssl x509 -in workspace/tmp/bob/client.certificate -text -noout

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


