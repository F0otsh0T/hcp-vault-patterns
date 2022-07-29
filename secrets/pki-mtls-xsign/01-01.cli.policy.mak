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
.PHONY: help all clean foundation create-policy delete-policy

################################################################################
# ALL
#
all: foundation create-policy #target ## All Targets

################################################################################
# CLEAN
#
clean: foundation delete-policy #target ## Clean

################################################################################
# FOUNDATION
#
foundation: foundation #target ## Set Foundational Tasks
	chmod 754 data/scripts/*

################################################################################
# CREATE VAULT POLICY FOR PKI TEST
#
create-policy: foundation #target ## Create Policy
	data/scripts/01-01.01.cli.policy.create.sh

################################################################################
# CREATE VAULT POLICY FOR PKI TEST
#
delete-policy: foundation #target ## Delete Policy
	data/scripts/01-01.02.cli.policy.delete.sh

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