#!/bin/sh

## 

set -e
set -x

## GENERATE LEAF CERT - CLIENT
#vault write -format=json smf_int_n11/issue/client common_name="client.n11.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > smf_int_n11_client.cert.json
vault write -format=json \
    smf_int_n11/issue/client \
    common_name="client.n11.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json

#    alt_names="client.n11.alice.smf.5gc.mobilecarrier.net" \
#    uri_sans="client.n11.alice.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/smf/server-n11/client.bundle
jq -r '.data.certificate' < workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json > workspace/tmp/smf/server-n11/client.pem
jq -r '.data.certificate' < workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json > workspace/tmp/smf/server-n11/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json >> workspace/tmp/smf/server-n11/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json > workspace/tmp/smf/server-n11/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json > workspace/tmp/smf/server-n11/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/server-n11/smf_int_n11_client.cert.json > workspace/tmp/smf/server-n11/client.serial
##cp workspace/tmp/smf/server-n11/client_chain.pem workspace/tmp/_archive/smf/n11/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/server-n11/client.pem workspace/tmp/smf/server-n11/client_chain.pem > workspace/tmp/smf/server-n11/client.bundle
#cat workspace/tmp/smf/server-n11/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json smf_int_n11/issue/server common_name="server.n11.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > smf_int_n11_server.cert.json
vault write -format=json \
    smf_int_n11/issue/server \
    common_name="server.n11.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json

#   alt_names="server.n11.alice.smf.5gc.mobilecarrier.net" \
#   uri_sans="server.n11.alice.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/smf/server-n11/server.bundle
jq -r '.data.certificate' < workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json > workspace/tmp/smf/server-n11/server.pem
jq -r '.data.certificate' < workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json > workspace/tmp/smf/server-n11/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json >> workspace/tmp/smf/server-n11/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json > workspace/tmp/smf/server-n11/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json > workspace/tmp/smf/server-n11/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/server-n11/smf_int_n11_server.cert.json > workspace/tmp/smf/server-n11/server.serial
##cp workspace/tmp/smf/server-n11/server_chain.pem workspace/tmp/_archive/smf/n11/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/server-n11/server.pem workspace/tmp/smf/server-n11/server_chain.pem > workspace/tmp/smf/server-n11/server.bundle
#cat workspace/tmp/smf/server-n11/server.bundle
