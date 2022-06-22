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
#   - jq
#   - curl
#   - PGP / pass
#   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,
################################################################################

ACTION ?= plan

##########
# CLEANUP
##########
.PHONY: clean
clean: #target
	echo "**************\n** CLEAN UP **\n**************"
	vault delete auth/approle/role/nginx
	vault auth disable approle
	vault secrets disable nginx
	vault policy delete nginx

##########
# ALL
##########
.PHONY: all
all: vault-policy vault-secrets-enable-kv2 auth-approle-enable auth-approle-write-role auth-approle-get-roleid auth-approle-get-secretid auth-approle-get-token #target

##########
# CREATE VAULT POLICY TO APPLY TO ROLE
# PERSONA: ADMIN
##########
.PHONY: 
vault-policy: #target
	echo "*******************\n** CREATE POLICY **\n*******************"
	vault policy write nginx policy-approle.hcl

##########
# CREATE VAULT POLICY TO APPLY TO ROLE
# PERSONA: ADMIN
##########
.PHONY: vault-secrets-enable-kv2
vault-secrets-enable-kv2: #target
	echo "***********************\n** ENABLE SECRET KV2 **\n***********************"
	vault secrets enable -version=2 -path=nginx kv
	vault kv put -format=json nginx/secret foo=bar | jq

##########
# ENABLE: VAULT AUTH APPROLE - CLI
# PERSONA: ADMIN
##########
.PHONY: auth-approle-enable
auth-approle-enable: #target
	echo "*************************\n** ENABLE AUTH APPROLE **\n*************************"
	vault auth enable approle

##########
# ENABLE: VAULT AUTH APPROLE - API
# # PERSONA: ADMIN
##########
.PHONY: auth-approle-enable-api
auth-approle-enable-api: #target
	echo "*************************\n** ENABLE AUTH APPROLE **\n*************************"
	curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
		--request POST \
		--data '{"type": "approle"}' \
		${VAULT_ADDR}/v1/sys/auth/approle

##########
# CREATE APPROLE ROLE WITH POLICY
# PERSONA: ADMIN
##########
.PHONY: auth-approle-write-role
auth-approle-write-role: #target
	echo "******************************\n** ENABLE AUTH APPROLE ROLE **\n******************************"
	vault write auth/approle/role/nginx token_policies="nginx" \
		token_ttl=1h \
		token_max_ttl=4h

##########
# GET ROLEID & SECUREID
# PERSONA: TRUSTED ENTITY OR ADMIN
##########
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

##########
# GET CLIENT TOKEN
# PERSONA: APP
##########
.PHONY: auth-approle-get-token
auth-approle-get-token: #target
	echo "**********************\n** GET CLIENT TOKEN **\n**********************"
	vault write -format=json auth/approle/login role_id="$(shell cat role-id.json | jq -r .data.role_id)" \
		secret_id="$(shell cat secret-id.json | jq -r .data.secret_id)" \
		| jq -r ".auth" > client_token.json
	cat client_token.json
	echo "AppRole Retrieved Client Token is $(shell jq -r .client_token < client_token.json)"

##########
# READ SECRET WITH CLIENT TOKEN
# PERONA: APP
##########
.PHONY: auth-approle-read-secret
auth-approle-read-secret: #target
	echo "*****************\n** READ SECRET **\n*****************"
	VAULT_TOKEN=$(shell jq -r .client_token < client_token.json) vault kv get nginx/secret
#	VAULT_TOKEN=$(shell jq -r .client_token < client_token.json) vault kv get -format=json nginx/secret

##########
# 
##########















