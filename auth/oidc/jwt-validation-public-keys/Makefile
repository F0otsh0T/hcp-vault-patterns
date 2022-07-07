################################################################################
# VAULT AUTH - APPROLE
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
#   - npm
#   - pem-jwk (```npm install -g pem-jwk```)
#   - jq
#   - curl
#   - PGP / pass
#   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,
################################################################################

################################
# DEFAULTS
################################
default: help

################################
# CLEAN
################################
.PHONY: clean
clean: #target ## Housekeeping.
	echo "**************\n** CLEAN UP **\n**************"
	vault auth disable jwt
	vault secrets disable nginx
	vault policy delete nginx

################################
# ALL
################################
.PHONY: all
all: k8s-sa-pubkey-jwk #target ## All Targets

################################
# RETRIEVE K8s SERVICEACCOUNT SIGNING PUBLIC KEY
################################
.PHONY: k8s-sa-pubkey-jwk
k8s-sa-pubkey-jwk: #target
	echo "*************************\n** RETRIEVE JWK => PEM **\n*************************"
	kubectl get --raw "$(shell kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri' | sed -r 's/.*\.[^/]+(.*)/\1/')" | jq -r '.keys[]' > jwk
	pem-jwk jwk > pem.rsa
	openssl rsa -RSAPublicKey_in -in pem.rsa -pubout -out pem.x509

################################
# ENABLE: VAULT AUTH JWT
################################
.PHONY: vault-auth-enable-jwt
vault-auth-enable-jwt: #target
	echo "*********************\n** ENABLE AUTH JWT **\n*********************"
	vault auth enable jwt

################################
# SET JWT VALIDATON PUBKEYS
# PERSONA: ADMIN
################################
.PHONY: vault-auth-jwt-config
vault-auth-jwt-config: #target
	echo "*******************************\n** CONFIGURE AUTH/JWT/CONFIG **\n*******************************"
	vault write auth/jwt/config jwt_validation_pubkeys="$(shell cat pem.x509)"
	vault read -format=json auth/jwt/config

################################
# ENABLE: VAULT AUTH APPROLE - API
# # PERSONA: ADMIN
################################
.PHONY: auth-approle-enable-api
auth-approle-enable-api: #target
	echo "*************************\n** ENABLE AUTH APPROLE **\n*************************"
	curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
		--request POST \
		--data '{"type": "approle"}' \
		${VAULT_ADDR}/v1/sys/auth/approle

################################
# CREATE APPROLE ROLE WITH POLICY
# PERSONA: ADMIN
################################
.PHONY: auth-approle-write-role
auth-approle-write-role: #target
	echo "******************************\n** ENABLE AUTH APPROLE ROLE **\n******************************"
	vault write auth/approle/role/nginx token_policies="nginx" \
		token_ttl=1h \
		token_max_ttl=4h

################################
# GET ROLEID & SECRETID
# PERSONA: TRUSTED ENTITY OR ADMIN
################################
.PHONY: auth-approle-get-roleid
auth-approle-get-roleid: #target
	echo "****************\n** GET ROLEID **\n****************"
	vault read -format=json auth/approle/role/nginx/role-id | jq > role-id.json
	export roleid=$(shell cat role-id.json | jq -r .data.role_id)
	echo ${roleid}

.PHONY: auth-approle-get-secretid
auth-approle-get-secretid: #target
	echo "******************\n** GET SECRETID **\n******************"
	vault write -format=json -force auth/approle/role/nginx/secret-id | jq > secret-id.json
	export secretid=$(shell cat secret-id.json | jq -r .data.secret_id)
	echo ${secretid}

################################
# GET CLIENT TOKEN
# PERSONA: APP
################################
.PHONY: auth-approle-get-token
auth-approle-get-token: #target
	echo "**********************\n** GET CLIENT TOKEN **\n**********************"
	vault write -format=json auth/approle/login role_id="$(shell cat role-id.json | jq -r .data.role_id)" \
		secret_id="$(shell cat secret-id.json | jq -r .data.secret_id)" \
		| jq -r ".auth" > client_token.json
	cat client_token.json
	echo "AppRole Retrieved Client Token is $(shell jq -r .client_token < client_token.json)"

################################
# READ SECRET WITH CLIENT TOKEN
# PERONA: APP
################################
.PHONY: auth-approle-read-secret
auth-approle-read-secret: #target
	echo "*****************\n** READ SECRET **\n*****************"
	VAULT_TOKEN=$(shell jq -r .client_token < client_token.json) vault kv get nginx/secret
#	VAULT_TOKEN=$(shell jq -r .client_token < client_token.json) vault kv get -format=json nginx/secret

################################
# 
################################















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