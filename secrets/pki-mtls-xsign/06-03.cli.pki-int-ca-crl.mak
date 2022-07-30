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
.PHONY: help all clean foundation pki-enable pki-disable pki-ca-root-create pki-ca-crl cert-list cert-read

################################################################################
# ALL
#
all: foundation pki-ca-crl #target ## All Targets

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
# CONFIGURE CA and CRL PUBLISH URLs
# SUB IP USED BELOW IN THE URL WITH YOUR VAULT SERVICE URL
pki-ca-crl: foundation #target ## Configure PKI CA and CRL URLs
# 	## Comment out below two lines export if you do not need to manually enter host.docker.internal for your Testbed
#	## These URLs need to be reachable from your PKI Consumers
#	vault write pki-bob/config/urls issuing_certificates="http://192.168.65.2:18200/v1/pki-bob/ca" crl_distribution_points="http://192.168.65.2:18200/v1/pki-bob/crl"
#	vault write pki-bob/config/urls issuing_certificates="${VAULT_ADDR}/v1/pki-bob/ca" crl_distribution_points="${VAULT_ADDR}/v1/pki-bob/crl"
#	export VAULT_ADDR_DOCKER='http://192.168.65.2:18200'
	data/scripts/06-03.01.cli.pki-int-ca-crl-client.sh
	data/scripts/06-03.02.cli.pki-int-ca-crl-server.sh

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