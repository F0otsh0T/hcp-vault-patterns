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
.PHONY: all clean foundation pki_server

################################################################################
# ALL
################################################################################
all: foundation pki_server #target ## All Targets

################################################################################
# CLEAN
################################################################################
clean: foundation #target ## Clean
	data/scripts/01-05.pki_server_disable.sh

################################################################################
# FOUNDATION
#
foundation: #target ## Set Foundational Tasks
	chmod 754 data/scripts/*

################################################################################
# PKI CA ROOT
#
pki_server: foundation #target ## PKI CA Root Mounts
	data/scripts/01-01.01.amf-self.sh
	data/scripts/01-02.01.nef-self.sh
	data/scripts/01-03.01.pcf-self.sh
	data/scripts/01-03.02.pcf-server-n7.sh
	data/scripts/01-03.03.pcf-server-n15.sh
	data/scripts/01-04.01.smf-self.sh
	data/scripts/01-04.02.smf-server-n11.sh
	data/scripts/01-04.03.smf-server-n29.sh

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
