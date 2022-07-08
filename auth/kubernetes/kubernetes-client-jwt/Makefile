################################################################################
# VAULT AUTH - KUBERNETES CLIENT JWT
#
# @file
# @version 0.1
#
##########
# PREREQUISITES
#   - Docker
#   - Kubernetes: K3d / K3s
#   - kubectl
#   - Vault CLI
#   - Terraform
#   - make
#   - jq
#   - curl
#   - PGP / pass
#   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,
################################################################################

################################
# DEFAULTS
################################
default: help

################################
# CLEAN
################################
.PHONY: clean
clean: #target ## Housekeeping.
	@echo "**************\n** CLEAN UP **\n**************"
	vault auth disable kubernetes
	vault secrets disable nginx
	vault policy delete global.crudl
	kubectl delete -f vault-auth-k8s-clusterrolebinding.yaml
	kubectl delete -f vault-auth-k8s-serviceaccount.yaml

################################
# ALL
################################
.PHONY: all
all: kubernetes-sa-crb kubernetes-harvest vault-policy secrets-enable-kv auth-enable-kubernetes auth-kubernetes-config auth-kubernetes-role #target ## All Targets


################################
# K8S: CREATE SERVICEACCOUNT & CLUSTERROLEBINDING
################################
.PHONY: kubernetes-sa-crb
kubernetes-sa-crb: #target ## Kubernetes Create ServiceAccount and ClusterRoleBinding.
	@echo "************************************************\n** CREATE SERVICEACCOUNT & CLUSTERROLEBINDING **\n************************************************"
	-kubectl create -f vault-auth-k8s-serviceaccount.yaml
	-kubectl create -f vault-auth-k8s-clusterrolebinding.yaml

################################
# K8S: HARVEST DATA FOR VAULT INPUT
################################
.PHONY: kubernetes-harvest
kubernetes-harvest: #target ## Kubernetes Harvest Data
	@echo "**********************************\n** HARVEST DATA FOR VAULT INPUT **\n**********************************"
	@sh kubernetes-harvest.sh && \
		cat kubernetes-harvest.cert && \
		cat kubernetes-harvest.json | jq

################################
# EXPORT HARVEST VARIABLES
################################
export VAULT_SA_NAME="$(shell jq -r '.VAULT_SA_NAME' < kubernetes-harvest.json)"
export SA_JWT_TOKEN="$(shell jq -r '.SA_JWT_TOKEN' < kubernetes-harvest.json)"
export SA_CA_CRT="$(shell jq -r '.SA_CA_CRT' < kubernetes-harvest.json)"
export SA_CA_CRT_NEWLINE="$(shell kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)"
export K8S_HOST="$(shell jq -r '.K8S_HOST' < kubernetes-harvest.json)"

################################
# CREATE VAULT POLICY TO APPLY TO ROLE
# PERSONA: ADMIN
################################
.PHONY: 
vault-policy: #target ## Vault Policy
	@echo "*******************\n** CREATE POLICY **\n*******************"
	-vault policy write global.crudl p.global.crudl.hcl

################################
# CREATE VAULT KV SECRETS
# PERSONA: ADMIN
################################
.PHONY: secrets-enable-kv
secrets-enable-kv: #target ## Vault Secrets Enable KVv2
	@echo "***********************\n** ENABLE SECRET KV2 **\n***********************"
	-vault secrets enable -version=2 -path=nginx kv
	-vault kv put -format=json nginx/secret foo=bar | jq

################################
# ENABLE: VAULT AUTH APPROLE - CLI
# PERSONA: ADMIN
################################
.PHONY: auth-enable-kubernetes
auth-enable-kubernetes: #target ## Vault Auth Enable Kubernetes
	@echo "****************************\n** ENABLE AUTH KUBERNETES **\n****************************"
	vault auth enable kubernetes

################################
# VAULT AUTH KUBERNETES CONFIG
# CLIENT APPLICATION JWT
# FOR KUBERNETES v1.21+ TO ISS
# AND SHORT LIVED TOKENS
################################
.PHONY: auth-kubernetes-config
auth-kubernetes-config: #target ## Vault Kubernetes Auth Configuration
	@echo "**********************************\n** WRITE AUTH KUBERNETES CONFIG **\n**********************************"
	@sh auth-kubernetes-config.sh

################################
# VAULT AUTH KUBERNETES ROLE
################################
.PHONY: auth-kubernetes-role
auth-kubernetes-role: #target ## Vault Kubernetes Role
	@echo "********************************\n** WRITE AUTH KUBERNETES ROLE **\n********************************"
	vault write auth/kubernetes/role/example \
	bound_service_account_names=$(shell jq '.VAULT_SA' < kubernetes-harvest.json) \
	bound_service_account_namespaces=default \
	policies=global.crudl \
	disable_iss_validation=true \
	ttl=24h

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