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
.PHONY: all clean foundation pki_int_role

################################################################################
# ALL
################################################################################
all: foundation pki_int_role #target ## All Targets

################################################################################
# CLEAN
################################################################################
clean: foundation #target ## Clean

################################################################################
# FOUNDATION
#
foundation: #target ## Set Foundational Tasks
	chmod 754 data/scripts/*

################################################################################
# PKI CA INTERMEDIATE
#
pki_int_role: foundation #target ## PKI Intermediate Roles
	data/scripts/03-01.01.amf_int_role.sh
	data/scripts/03-01.02.amf_int_n11_role.sh
	data/scripts/03-01.03.amf_int_n15_role.sh
	data/scripts/03-02.01.nef_int_role.sh
	data/scripts/03-02.02.nef_int_n29_role.sh
	data/scripts/03-03.01.pcf_int_role.sh
	data/scripts/03-03.02.pcf_int_n7_role.sh
	data/scripts/03-03.03.pcf_int_n15_role.sh
	data/scripts/03-04.01.smf_int_role.sh
	data/scripts/03-04.02.smf_int_n7_role.sh
	data/scripts/03-04.03.smf_int_n11_role.sh
	data/scripts/03-04.04.smf_int_n29_role.sh

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
