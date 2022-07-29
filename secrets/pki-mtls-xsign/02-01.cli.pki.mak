################################################################################
# VAULT PKI CLI - PKI_INT CREATE & PROCESS INTERMEDIATE CERTIFICATE
#
# @file
# @version 0.1
#
##########
# PREREQUISITES
#   - make
#   - jq
#   - curl
#   - Vault CLI
#   - Terraform
#   - make
#   - jq
#   - curl
#   - PGP/GPG/PASS
#   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,
################################################################################

################################################################################
# DEFAULTS
#
default: help
.PHONY: help all clean foundation pki-enable pki-disable 

################################################################################
# ALL
#
all: foundation pki-enable #target ## All Targets

################################################################################
# CLEAN
#
clean: foundation pki-disable #target ## Clean

################################################################################
# FOUNDATION
#
foundation: #target ## Set Foundational Tasks
	@chmod 754 data/scripts/*

################################################################################
# ENABLE VAULT PKI SECRETS ENGINE
#
pki-enable: foundation #target ## Secrets Enable PKI
	data/scripts/02-01.01.cli.pki-root-client.sh
	data/scripts/02-01.02.cli.pki-root-server.sh

################################################################################
# DISABLE VAULT PKI SECRETS ENGINE
#
pki-disable: foundation #target ## Secrets Disable PKI
	data/scripts/02-01.03.cli.pki-root-disable.sh

################################################################################
# HELP
# REF GH @ jen20/hashidays-nyc/blob/master/terraform/GNUmakefile
#
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