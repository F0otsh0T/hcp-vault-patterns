#! /bin/sh

HOST="$(jq -r '.K8S_HOST' < kubernetes-harvest.json)"
#echo $HOST
#echo "$HOST"


CERT="$(cat <<EOF
$(cat kubernetes-harvest.cert)
EOF
)"

#echo $CERT
#echo "$CERT"

vault write auth/kubernetes/config \
    kubernetes_host="$HOST" \
    kubernetes_ca_cert="$CERT" \
    issuer="https://kubernetes.default.svc.cluster.local"