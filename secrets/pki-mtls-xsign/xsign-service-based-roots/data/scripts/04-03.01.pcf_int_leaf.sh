#!/bin/sh

## 

set -e
set -x

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pcf_int/issue/client common_name="client.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" > pcf_int_client.cert.json
vault write -format=json \
    pcf_int/issue/client \
    common_name="client.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/pcf/server/pcf_int_client.cert.json

#    alt_names="client.bob.pcf.5gc.mobilecarrier.net" \
#    uri_sans="client.bob.pcf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/pcf/server/client.bundle
jq -r '.data.certificate' < workspace/tmp/pcf/server/pcf_int_client.cert.json > workspace/tmp/pcf/server/client.pem
jq -r '.data.certificate' < workspace/tmp/pcf/server/pcf_int_client.cert.json > workspace/tmp/pcf/server/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/pcf/server/pcf_int_client.cert.json >> workspace/tmp/pcf/server/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/pcf/server/pcf_int_client.cert.json > workspace/tmp/pcf/server/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/pcf/server/pcf_int_client.cert.json > workspace/tmp/pcf/server/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/pcf/server/pcf_int_client.cert.json > workspace/tmp/pcf/server/client.serial
#cp workspace/tmp/pcf/server/client_chain.pem workspace/tmp/_archive/pcf/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/pcf/server/client.pem workspace/tmp/pcf/server/client_chain.pem > workspace/tmp/pcf/server/client.bundle
#cat workspace/tmp/pcf/server/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pcf_int/issue/server common_name="server.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" > pcf_int_server.cert.json
vault write -format=json \
    pcf_int/issue/server \
    common_name="server.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/pcf/server/pcf_int_server.cert.json

#    alt_names="server.bob.pcf.5gc.mobilecarrier.net" \
#    uri_sans="server.bob.pcf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/pcf/server/server.bundle
jq -r '.data.certificate' < workspace/tmp/pcf/server/pcf_int_server.cert.json > workspace/tmp/pcf/server/server.pem
jq -r '.data.certificate' < workspace/tmp/pcf/server/pcf_int_server.cert.json > workspace/tmp/pcf/server/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/pcf/server/pcf_int_server.cert.json >> workspace/tmp/pcf/server/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/pcf/server/pcf_int_server.cert.json > workspace/tmp/pcf/server/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/pcf/server/pcf_int_server.cert.json > workspace/tmp/pcf/server/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/pcf/server/pcf_int_server.cert.json > workspace/tmp/pcf/server/server.serial
#cp workspace/tmp/pcf/server/server_chain.pem workspace/tmp/_archive/pcf/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/pcf/server/server.pem workspace/tmp/pcf/server/server_chain.pem > workspace/tmp/pcf/server/server.bundle
#cat workspace/tmp/pcf/server/server.bundle
