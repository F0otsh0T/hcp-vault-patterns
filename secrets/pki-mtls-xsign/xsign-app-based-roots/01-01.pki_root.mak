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

################################
# DEFAULTS
################################
default: help
.PHONY: all clean foundation pki_root

################################################################################
# ALL
################################################################################
all: foundation pki_root #target ## All Targets

################################################################################
# CLEAN
################################################################################
clean: foundation #target ## Clean
	data/scripts/01-05.pki_root_disable.sh

################################################################################
# FOUNDATION
#
foundation: #target ## Set Foundational Tasks
	chmod 754 data/scripts/*

################################################################################
# PKI CA ROOT
#
pki_root: foundation #target ## PKI CA Root Mounts
	data/scripts/01-01.pki_root_amf.sh
	data/scripts/01-02.pki_root_nef.sh
	data/scripts/01-03.pki_root_pcf.sh
	data/scripts/01-04.pki_root_smf.sh

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
