#!/bin/sh

## 

set -e
set -x

## GENERATE LEAF CERT - CLIENT
#vault write -format=json smf_int/issue/client common_name="client.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > smf_int_client.cert.json
vault write -format=json \
    smf_int/issue/client \
    common_name="client.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/server/smf_int_client.cert.json

#    alt_names="client.alice.smf.5gc.mobilecarrier.net" \
#    uri_sans="client.alice.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/smf/server/client.bundle
jq -r '.data.certificate' < workspace/tmp/smf/server/smf_int_client.cert.json > workspace/tmp/smf/server/client.pem
jq -r '.data.certificate' < workspace/tmp/smf/server/smf_int_client.cert.json > workspace/tmp/smf/server/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/server/smf_int_client.cert.json >> workspace/tmp/smf/server/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/server/smf_int_client.cert.json > workspace/tmp/smf/server/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/server/smf_int_client.cert.json > workspace/tmp/smf/server/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/server/smf_int_client.cert.json > workspace/tmp/smf/server/client.serial
#cp workspace/tmp/smf/server/client_chain.pem workspace/tmp/_archive/smf/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/server/client.pem workspace/tmp/smf/server/client_chain.pem > workspace/tmp/smf/server/client.bundle
#cat workspace/tmp/smf/server/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json smf_int/issue/server common_name="server.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" > smf_int_server.cert.json
vault write -format=json \
    smf_int/issue/server \
    common_name="server.alice.smf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/smf/server/smf_int_server.cert.json

#    alt_names="server.alice.smf.5gc.mobilecarrier.net" \
#    uri_sans="server.alice.smf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/smf/server/server.bundle
jq -r '.data.certificate' < workspace/tmp/smf/server/smf_int_server.cert.json > workspace/tmp/smf/server/server.pem
jq -r '.data.certificate' < workspace/tmp/smf/server/smf_int_server.cert.json > workspace/tmp/smf/server/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/smf/server/smf_int_server.cert.json >> workspace/tmp/smf/server/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/smf/server/smf_int_server.cert.json > workspace/tmp/smf/server/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/smf/server/smf_int_server.cert.json > workspace/tmp/smf/server/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/smf/server/smf_int_server.cert.json > workspace/tmp/smf/server/server.serial
#cp workspace/tmp/smf/server/server_chain.pem workspace/tmp/_archive/smf/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/smf/server/server.pem workspace/tmp/smf/server/server_chain.pem > workspace/tmp/smf/server/server.bundle
#cat workspace/tmp/smf/server/server.bundle
