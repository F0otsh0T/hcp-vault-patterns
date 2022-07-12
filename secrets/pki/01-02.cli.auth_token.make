################################################################################
# VAULT PKI CLI - AUTH METHOD
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
all: auth-token vault-login #target ## All Targets

##########
# CREATE AUTH TOKEN BASED ON SELECTED POLICY (ASSUMING POLICY CREATED IN PREVIOUS STEPS)
#
.PHONY: 
auth-token: #target ## Generate Client Token
	vault token create -policy=pki_test -display-name=token-pki_test -format=json | jq > workspace/tmp/auth-token.json
#	cat workspace/tmp/auth-token.json | jq -r '.auth.client_token' > workspace/tmp/auth-token
	cat workspace/tmp/auth-token.json | jq -r '.auth.client_token' | pass insert -e vault/pki_test

##########
# LOGIN TO VAULT WITH NEWLY CREATED AUTH TOKEN
#
.PHONY: 
vault-login: #target ## Vault Login
	vault login $(shell pass vault/pki_test)

################################################################################

##########
# REVOKE AUTH TOKEN
#
.PHONY: 
auth-token-revoke: #target ## Revoke Client Token
#	vault token revoke $(shell pass vault/pki_test)
	vault token revoke $(shell cat workspace/tmp/auth-token.json | jq -r '.auth.client_token')


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






