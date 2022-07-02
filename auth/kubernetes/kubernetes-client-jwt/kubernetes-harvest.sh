#! /bin/sh

################################
# SERVICE ACCOUNT  NAME
################################
export VAULT_SA=$(kubectl get sa vault-auth -o jsonpath="{.metadata.name}")
#echo $VAULT_SA

################################
# SERVICE ACCOUNT SECRET NAME
################################
export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
#echo $VAULT_SA_NAME

################################
# SERVICE ACCOUNT JWT TOKEN
################################
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME --output 'go-template={{ .data.token }}' | base64 --decode)
#echo $SA_JWT_TOKEN

################################
# SERVICE ACCOUNT PULIC CERTIFICATE
################################
export SA_CA_CRT=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode | awk '{printf "%s\\n", $0}')
#echo $SA_CA_CRT
export SA_CA_CRT_NEWLINE=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
#echo $SA_CA_CRT_NEWLINE

################################
# KUBERNETES KUBEAPI URL
################################
export K8S_HOST_INTERNAL=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')
#echo $K8S_HOST_INTERNAL

################################
# KUBERNETES KUBEAPI PORT
################################
FIELDS=($(echo $K8S_HOST_INTERNAL \
  | awk '{split($0, arr, /[\/:]*/); for (x in arr) { print arr[x] }}'))
#  | awk '{split($0, arr, /[\/\@:]*/); for (x in arr) { print arr[x] }}'))
#echo ${FIELDS[0]}
#echo ${FIELDS[1]}
#echo ${FIELDS[2]}

export K8S_HOST_PORT=${FIELDS[1]}
#echo $K8S_HOST_PORT

################################
# DOCKER NETWORK HOST INTERNAL
################################
export K8S_CLUSTER_NAME=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].name}')
#echo $K8S_CLUSTER_NAME

export HOST_DOCKER_INTERNAL=$(docker exec $K8S_CLUSTER_NAME-server-0 nslookup host.docker.internal | awk '/^Address: / { print $2 }')
#echo $HOST_DOCKER_INTERNAL


################################
# KUBERNETES FORMAT URL FOR DOCKER NETWORK
################################
export K8S_HOST=https://$HOST_DOCKER_INTERNAL:$K8S_HOST_PORT
#echo $K8S_HOST

################################
# WRITE DATA FOR VAULT INPUT
################################
cat <<EOF > ./kubernetes-harvest.json
{
    "VAULT_SA": "$VAULT_SA",
    "VAULT_SA_NAME": "$VAULT_SA_NAME",
    "SA_JWT_TOKEN": "$SA_JWT_TOKEN",
    "SA_CA_CRT": "$SA_CA_CRT",
    "K8S_HOST": "$K8S_HOST"
}
EOF

################################
# WRITE MULTILINE STRING FOR CRT
################################
cat <<EOF > ./kubernetes-harvest.cert
$SA_CA_CRT_NEWLINE
EOF
