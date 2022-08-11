#!/bin/sh

## 

set -e
set -x

## GENERATE LEAF CERT - CLIENT
#vault write -format=json nef_int_n29/issue/client common_name="client.n29.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" > nef_int_n29_client.cert.json
vault write -format=json \
    nef_int_n29/issue/client \
    common_name="client.n29.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json

#    alt_names="client.n29.charlie.nef.5gc.mobilecarrier.net" \
#    uri_sans="client.n29.charlie.nef.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/nef/client-n29/client.bundle
jq -r '.data.certificate' < workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json > workspace/tmp/nef/client-n29/client.pem
jq -r '.data.certificate' < workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json > workspace/tmp/nef/client-n29/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json >> workspace/tmp/nef/client-n29/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json > workspace/tmp/nef/client-n29/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json > workspace/tmp/nef/client-n29/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/nef/client-n29/nef_int_n29_client.cert.json > workspace/tmp/nef/client-n29/client.serial
#cp workspace/tmp/nef/client-n29/client_chain.pem workspace/tmp/_archive/nef/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/nef/client-n29/client.pem workspace/tmp/nef/client-n29/client_chain.pem > workspace/tmp/nef/client-n29/client.bundle
#cat workspace/tmp/nef/client-n29/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json nef_int_n29/issue/server common_name="server.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" > nef_int_n29_server.cert.json
vault write -format=json \
    nef_int_n29/issue/server \
    common_name="server.charlie.nef.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json

#    alt_names="server.charlie.nef.5gc.mobilecarrier.net" \
#    uri_sans="server.charlie.nef.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/nef/client-n29/server.bundle
jq -r '.data.certificate' < workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json > workspace/tmp/nef/client-n29/server.pem
jq -r '.data.certificate' < workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json > workspace/tmp/nef/client-n29/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json >> workspace/tmp/nef/client-n29/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json > workspace/tmp/nef/client-n29/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json > workspace/tmp/nef/client-n29/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/nef/client-n29/nef_int_n29_server.cert.json > workspace/tmp/nef/client-n29/server.serial
#cp workspace/tmp/nef/client-n29/server_chain.pem workspace/tmp/_archive/nef/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/nef/client-n29/server.pem workspace/tmp/nef/client-n29/server_chain.pem > workspace/tmp/nef/client-n29/server.bundle
#cat workspace/tmp/nef/client-n29/server.bundle
