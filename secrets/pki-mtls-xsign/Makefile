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
	make -f 01-01.cli.policy.mak all
	make -f 02-01.cli.pki.mak all
	sleep 1
	make -f 02-02.cli.pki-cert.mak all
	make -f 02-03.cli.pki-ca-crl.mak all
	sleep 1
	make -f 03-01.cli.pki-int.mak all
	sleep 1
	make -f 04-01.cli.pki-xsign-clientxserver.mak all
	make -f 04-02.cli.pki-xsign-serverxclient.mak all
	make -f 04-03.cli.pki-int-sign-client.mak all
	make -f 04-04.cli.pki-int-sign-server.mak all
	make -f 04-05.cli.pki-int-xsign-clientxserver.mak all
	make -f 04-06.cli.pki-int-xsign-serverxclient.mak all
	make -f 05-01.cli.pki-int-client-role.mak all
	make -f 05-02.cli.pki-int-server-role.mak all
	make -f 06-01.cli.pki-int-client-cert.mak all
	make -f 06-02.cli.pki-int-server-cert.mak all
	cd workspace && make -f Makefile all

################################################################################
# CLEAN
################################################################################
clean: #target ## Clean
	cd workspace && make -f Makefile clean
	make -f 03-01.cli.pki-int.mak clean
	sleep 2
	make -f 02-01.cli.pki.mak clean
	sleep 1
	make -f 01-01.cli.policy.mak clean


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