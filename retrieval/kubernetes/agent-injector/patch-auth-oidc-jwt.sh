#! /bin/sh

sleep 5
kubectl -n default patch deployments k8stools-auth-oidc-jwt --patch "$(cat patch-auth-oidc-jwt.yaml)"