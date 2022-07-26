################################################################################
# VAULT PKI CLI - PKI_INT CREATE & PROCESS INTERMEDIATE CERTIFICATE
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
.PHONY: all clean

################################################################################
# ALL
################################################################################
all: #target ## All Targets
	make -f 02-01.cli.pki.make all
	make -f 02-01.cli.pki.make cert-read
	sleep 10
	make -f 02-02.cli.pki_int.make all
	sleep 10
	make -f 03-01.cli.intermediate_create.make all
	cd workspace && make -f Makefile all

################################################################################
# CLEAN
################################################################################
clean: #target ## Clean
	make -f 02-02.cli.pki_int.make pki_int-disable
	sleep 5
	make -f 02-01.cli.pki.make pki-disable
	cd workspace && make -f Makefile clean

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
