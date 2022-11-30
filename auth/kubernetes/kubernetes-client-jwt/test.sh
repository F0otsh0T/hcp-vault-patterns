#! /bin/bash





export SA_CA_CRT_NEWLINE="$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)"
echo $SA_CA_CRT_NEWLINE

TEST0="$(cat <<-EOF
$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
EOF
)"

echo $TEST0
echo "$TEST0"


TEST1="$(cat <<EOF
$(cat kubernetes-harvest.cert)
EOF
)"

echo $TEST1
echo "$TEST1"