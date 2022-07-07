#! /bin/sh

export VAULT_AGENT_SA_TOKEN_NAME="$(kubectl get sa vault -o jsonpath="{.secrets[*]['name']}")"
#echo $VAULT_AGENT_SA_TOKEN_NAME

cat > vault-sa-token-secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: $VAULT_AGENT_SA_TOKEN_NAME
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF

kubectl apply -f vault-sa-token-secret.yaml || true

kubectl get secret $VAULT_AGENT_SA_TOKEN_NAME -o json