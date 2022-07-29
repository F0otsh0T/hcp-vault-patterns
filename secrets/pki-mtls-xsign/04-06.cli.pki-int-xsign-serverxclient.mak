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
.PHONY: help all clean foundation pki-int-xsign-server-csr pki-int-xsign-client-sign pki-int-xsign-server-import

################################################################################
# ALL
#
all: foundation pki-int-xsign-server-csr pki-int-xsign-client-sign pki-int-xsign-server-import #target ## All Targets

################################################################################
# CLEAN
#
clean: foundation #target ## Clean

################################################################################
# FOUNDATION
#
foundation: #target ## Set Foundational Tasks
	chmod 754 data/scripts/*

################################################################################
# CLIENT CA ROOT CREATE CSR
#
pki-int-xsign-server-csr: foundation #target ## Server CA Root Creates CSR
	data/scripts/04-06.01.cli.pki-int-xsign-serverxclient-csr.sh

################################################################################
# SERVER CA ROOT SIGNS CLIENT CA CSR
#
pki-int-xsign-client-sign: foundation #target ## Client CA Root Signs CSR
	data/scripts/04-06.02.cli.pki-int-xsign-serverxclient-sign.sh

################################################################################
# CLIENT CA ROOT IMPORT SIGNED CERT
#
pki-int-xsign-server-import: foundation #target ## Server CA Root Imports Signed Cert
	data/scripts/04-06.03.cli.pki-int-xsign-serverxclient-import.sh

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