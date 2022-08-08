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
.PHONY: all clean foundation xsign

################################################################################
# ALL
################################################################################
all: foundation xsign #target ## All Targets

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
xsign: foundation #target ## Cross-Sign
#	## XSign: AMF x NEF
#	data/scripts/03-01.01.xsign_amfxnef.sh
#	## XSign: AMF x PCF
#	data/scripts/03-01.02.xsign_amfxpcf.sh
#	## XSign: AMF x SMF
#	data/scripts/03-01.03.xsign_amfxsmf.sh
#	## XSign: NEF x AMF
#	data/scripts/03-02.01.xsign_nefxamf.sh
#	## XSign: NEF x PCF
#	data/scripts/03-02.02.xsign_nefxpcf.sh
#	## XSign: NEF x SMF
#	data/scripts/03-02.03.xsign_nefxsmf.sh
#	## XSign: PCF x AMF [N15]
#	data/scripts/03-03.01.xsign_pcfxamf.sh
	data/scripts/03-03.03.xsign_pcfxamfn15.sh
#	## XSign: PCF x NEF
#	data/scripts/03-03.02.xsign_pcfxnef.sh
#	## XSign: PCF x SMF [N7]
#	data/scripts/03-03.03.xsign_pcfxsmf.sh
	data/scripts/03-03.03.xsign_pcfxsmfn7.sh
#	## XSign: SMF x AMF [N11]
#	data/scripts/03-04.01.xsign_smfxamf.sh
	data/scripts/03-04.01.xsign_smfxamfn11.sh
#	## XSign: SMF x NEF [N29]
#	data/scripts/03-04.02.xsign_smfxnef.sh
	data/scripts/03-04.02.xsign_smfxnefn29.sh
#	## XSign: SMF x PCF
#	data/scripts/03-04.03.xsign_smfxpcf.sh

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
