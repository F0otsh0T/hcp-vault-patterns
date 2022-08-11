#!/bin/sh

## 

set -e
set -x

## GENERATE LEAF CERT - CLIENT
#vault write -format=json amf_int/issue/client common_name="client.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > amf_int_client.cert.json
vault write -format=json \
    amf_int/issue/client \
    common_name="client.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/server/amf_int_client.cert.json

#    alt_names="client.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="client.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/amf/server/client.bundle
jq -r '.data.certificate' < workspace/tmp/amf/server/amf_int_client.cert.json > workspace/tmp/amf/server/client.pem
jq -r '.data.certificate' < workspace/tmp/amf/server/amf_int_client.cert.json > workspace/tmp/amf/server/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/server/amf_int_client.cert.json >> workspace/tmp/amf/server/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/server/amf_int_client.cert.json > workspace/tmp/amf/server/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/server/amf_int_client.cert.json > workspace/tmp/amf/server/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/server/amf_int_client.cert.json > workspace/tmp/amf/server/client.serial
#cp workspace/tmp/amf/server/client_chain.pem workspace/tmp/_archive/amf/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/server/client.pem workspace/tmp/amf/server/client_chain.pem > workspace/tmp/amf/server/client.bundle
#cat workspace/tmp/amf/server/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json amf_int/issue/server common_name="server.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" > amf_int_server.cert.json
vault write -format=json \
    amf_int/issue/server \
    common_name="server.carol.amf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/amf/server/amf_int_server.cert.json

#    alt_names="server.carol.amf.5gc.mobilecarrier.net" \
#    uri_sans="server.carol.amf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/amf/server/server.bundle
jq -r '.data.certificate' < workspace/tmp/amf/server/amf_int_server.cert.json > workspace/tmp/amf/server/server.pem
jq -r '.data.certificate' < workspace/tmp/amf/server/amf_int_server.cert.json > workspace/tmp/amf/server/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/amf/server/amf_int_server.cert.json >> workspace/tmp/amf/server/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/amf/server/amf_int_server.cert.json > workspace/tmp/amf/server/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/amf/server/amf_int_server.cert.json > workspace/tmp/amf/server/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/amf/server/amf_int_server.cert.json > workspace/tmp/amf/server/server.serial
#cp workspace/tmp/amf/server/server_chain.pem workspace/tmp/_archive/amf/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/amf/server/server.pem workspace/tmp/amf/server/server_chain.pem > workspace/tmp/amf/server/server.bundle
#cat workspace/tmp/amf/server/server.bundle
