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

################################################################################
# ALL
################################################################################
all: cert-revoke cert-tidy #target

##########
# LIST CERTS
#
cert-list: #target
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request LIST ${VAULT_ADDR}/v1/pki-bob/certs | jq
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request LIST ${VAULT_ADDR}/v1/pki_int-bob/certs | jq

##########
# READ CERT
#
cert-read: #target
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request GET ${VAULT_ADDR}/v1/pki_int-bob/cert/$(shell cat workspace/tmp/bob/server.serial_number) | jq

##########
# REVOKE INTERMEDIATE CERTIFICATE
#
cert-revoke: #target
	touch cert-revoke.json
	cp body/cert-revoke.json bodycert-revoke.json.$(shell date +"%Y%m%d-%H%M%S")
	echo '{ "serial_number": "$(shell cat workspace/tmp/bob/server.serial_number)" }' > cert-revoke.json
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request POST --data @body/cert-revoke.json ${VAULT_ADDR}/v1/pki_int-bob/revoke | jq > workspace/tmp/bob/revoke.out

##########
# CERTIFICATE TIDY
#
cert-tidy: #target
	curl -k --header "X-Vault-Token: $(shell pass vault/token)" --request POST --data @body/cert-tidy.json ${VAULT_ADDR}/v1/pki_int-bob/tidy | jq > workspace/tmp/bob/tidy.out