#! /bin/sh

sleep 5
kubectl -n default patch deployments k8stools-auth-k8s --patch "$(cat patch-auth-k8s.yaml)"
