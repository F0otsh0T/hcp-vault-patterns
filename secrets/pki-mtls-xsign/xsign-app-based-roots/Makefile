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
.PHONY: all clean

################################################################################
# ALL
################################################################################
all: #target ## All Targets
#	# Set Up Directories
	make -f 00-01.setup_directories.mak all
#	# PKI CA Root Mounts - Enable
	make -f 01-01.pki_root.mak all
	sleep 1
#	# PKI CA Intermediate Mounts - Enable
	make -f 02-01.pki_int.mak all
	sleep 1
#	# CROSS SIGN
	make -f 03-01.xsign.mak all
#	# PKI Intermediate Roles
	make -f 04-01.pki_int_role.mak all
#	# Generate PKI Intermediate Certficates
	make -f 05-01.pki_int_leaf.mak all
#	# Setup Container Application Templates
	make -f 06-01.cnf_template.mak all
# 	# Build and Deploy Container Applications
	cd workspace && make -f Makefile all

################################################################################
# CLEAN
################################################################################
clean: #target ## Clean
	cd workspace && make -f Makefile clean
	sleep 1
	make -f 02-01.pki_int.mak clean
	sleep 1
	make -f 01-01.pki_root.mak clean



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