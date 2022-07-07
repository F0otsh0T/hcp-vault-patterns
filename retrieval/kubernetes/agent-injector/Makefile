################################################################################
# VAULT SECRETS RETRIEVAL - KUBERNETES SIDECAR AGENT INJECTOR
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
	-kubectl delete -f k8stools-deploy-auth-oidc-jwt.yaml
	-kubectl delete -f k8stools-deploy-auth-k8s.yaml
	-kubectl delete -f vault-sa-token-secret.yaml
	-helm uninstall vault
	-kubectl delete -f external-vault.yaml

################################
# CLEAN K8STOOLS-AUTH-K8S DEPLOYMENT
################################
.PHONY: clean-deploy-auth-k8s
clean-deploy-auth-k8s: #target ## Housekeeping.
	@echo "**************\n** CLEAN UP **\n**************"
	-kubectl delete -f k8stools-deploy-auth-k8s.yaml

################################
# CLEAN K8STOOLS-AUTH-OIDC-JWT DEPLOYMENT
################################
.PHONY: clean-deploy-auth-oidc-jwt
clean-deploy-auth-oidc-jwt: #target ## Housekeeping.
	@echo "**************\n** CLEAN UP **\n**************"
	-kubectl delete -f k8stools-deploy-auth-oidc-jwt.yaml

################################
# ALL 
################################
.PHONY: all
all:  #target ## ALL Targets

################################
# ALL TARGETS FOR AUTH K8S
################################
.PHONY: all-auth-kubernetes
all-auth-kubernetes: external-vault helm-vault-agent-install vault-sa-token deploy-app-auth-kubernetes patch-app-auth-kubernetes #target ## All Targets for AUTH Kubernetes

################################
# ALL TARGETS FOR AUTH OIDC JWT PUBLIC KEY
################################
.PHONY: all-auth-oidc-jwt
all-auth-oidc-jwt: external-vault helm-vault-agent-install vault-sa-token deploy-app-auth-oidc-jwt patch-app-auth-oidc-jwt #target ## All Targets for AUTH OIDC JWT Public Key

################################
# K8S/VAULT: CREATE SERVICE FOR EXTERNAL VAULT PROXY
################################
.PHONY: external-vault
external-vault: #target ## Kubernetes Create ServiceAccount and ClusterRoleBinding.
	@echo "***********************************\n** CREATE EXTERNAL VAULT SERVICE **\n***********************************"
	-kubectl create -f external-vault.yaml

################################
# K8S/VAULT: HELM INSTALL VAULT AGENT INJECTOR
################################
.PHONY: helm-vault-agent-install
helm-vault-agent-install: #target ## Kubernetes Harvest Data
	@echo "**********************************\n** HARVEST DATA FOR VAULT INPUT **\n**********************************"
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo update
	-helm install vault hashicorp/vault \
		--set "injector.externalVaultAddr=http://external-vault:8200"
	kubectl -n default get pods
	sleep 15

################################
# VAULT SERVICEACCOUNT TOKEN SECRET
# KUBERNETES 1.24+
################################
.PHONY: vault-sa-token
vault-sa-token: #target ## Vault Agent Service Account Token Secret
	@echo "**********************************************\n** VAULT AGENT SERVICE ACCOUNT TOKEN SECRET **\n**********************************************"
	@-sh vault-sa-token.sh

################################
# K8S: DEPLOY APPLICATION - AUTH K8S
################################
.PHONY: deploy-app-auth-kubernetes
deploy-app-auth-kubernetes:  #target ## Deploy Application Auth Kubernetes
	@echo "************************\n** DEPLOY APPLICATION **\n************************"
	kubectl apply -f k8stools-deploy-auth-k8s.yaml
	sleep 5

################################
# K8S: PATCH / ANNOTATE DEPLOYMENT - AUTH K8S
################################
.PHONY: patch-app-auth-kubernetes
patch-app-auth-kubernetes:  #target ## Patch and Annotate Application Auth Kubernetes
	@echo "***********************\n** PATCH APPLICATION **\n***********************"
	sh patch-auth-k8s.sh
#	kubectl -n default patch deployments k8stools-auth-k8s --patch "$(shell cat patch-auth-k8s.yaml)"
	sleep 5
	kubectl get pods --selector=app=k8stools-auth-k8s
	@echo "**************************\n** GET INJECTED SECRETS **\n**************************"
	kubectl exec deployments/k8stools-auth-k8s -c k8stools-auth-k8s -- cat /vault/secrets/kv /vault/secrets/kv.json

################################
# K8S: DEPLOY APPLICATION - AUTH OIDC JWT PUBLIC KEY
################################
.PHONY: deploy-app-auth-oidc-jwt
deploy-app-auth-oidc-jwt:  #target ## Deploy Application Auth OIDC JWT Public Key
	@echo "************************\n** DEPLOY APPLICATION **\n************************"
	kubectl apply -f k8stools-deploy-auth-oidc-jwt.yaml
	sleep 5

################################
# K8S: PATCH / ANNOTATE DEPLOYMENT - AUTH OIDC JWT PUBLIC KEY
################################
.PHONY: patch-app-auth-oidc-jwt
patch-app-auth-oidc-jwt:  #target ## Patch and Annotate Application Auth OIDC JWT Public Key
	@echo "***********************\n** PATCH APPLICATION **\n***********************"
	@sh patch-auth-oidc-jwt.sh
#	kubectl -n default patch deployments k8stools-auth-oidc-jwt --patch "$(shell cat patch-auth-oidc-jwt.yaml)"
	sleep 5
	kubectl get pods --selector=app=k8stools-auth-oidc-jwt
	@echo "**************************\n** GET INJECTED SECRETS **\n**************************"
	kubectl exec deployments/k8stools-auth-oidc-jwt -c k8stools-auth-oidc-jwt -- cat /vault/secrets/kv /vault/secrets/kv.json

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