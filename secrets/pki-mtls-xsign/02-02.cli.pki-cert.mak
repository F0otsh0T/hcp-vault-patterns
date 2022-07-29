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
.PHONY: help all clean foundation pki-root-create cert-list cert-read

################################################################################
# ALL
#
all: foundation pki-root-create cert-list cert-read #target ## All Targets

################################################################################
# CLEAN
#
clean: foundation  #target ## Clean

################################################################################
# FOUNDATION
#
foundation: #target ## Set Foundational Tasks
	@chmod 754 data/scripts/*

################################################################################
# CREATE INTERNAL CA ROOT CERTIFICATE
#
pki-root-create: foundation #target ## Create CA Root
	data/scripts/02-02.01.cli.pki-root-cert-client.sh
	data/scripts/02-02.02.cli.pki-root-cert-server.sh

################################################################################
# LIST CERTFICATES
#
cert-list: foundation #target ## List CA Root Certs
	data/scripts/02-02.03.cli.pki-cert-list.sh

################################################################################
# READ CERTFICATES
#
cert-read: foundation #target ## Read CA Root Certs
	data/scripts/02-02.04.cli.pki-cert-read.sh

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