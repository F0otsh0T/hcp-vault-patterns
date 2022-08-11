#!/bin/sh

## 

set -e
set -x

## GENERATE LEAF CERT - CLIENT
#vault write -format=json pcf_int_n15/issue/client common_name="client.n15.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" > pcf_int_n15_client.cert.json
vault write -format=json \
    pcf_int_n15/issue/client \
    common_name="client.n15.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json

#    alt_names="client.n15.bob.pcf.5gc.mobilecarrier.net" \
#    uri_sans="client.n15.bob.pcf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - CLIENT
#touch workspace/tmp/pcf/server-n15/client.bundle
jq -r '.data.certificate' < workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json > workspace/tmp/pcf/server-n15/client.pem
jq -r '.data.certificate' < workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json > workspace/tmp/pcf/server-n15/client_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json >> workspace/tmp/pcf/server-n15/client_chain.pem
jq -r '.data.private_key' < workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json > workspace/tmp/pcf/server-n15/client_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json > workspace/tmp/pcf/server-n15/client_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/pcf/server-n15/pcf_int_n15_client.cert.json > workspace/tmp/pcf/server-n15/client.serial
##cp workspace/tmp/pcf/server-n15/client_chain.pem workspace/tmp/_archive/pcf/server/client_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/pcf/server-n15/client.pem workspace/tmp/pcf/server-n15/client_chain.pem > workspace/tmp/pcf/server-n15/client.bundle
#cat workspace/tmp/pcf/server-n15/client.bundle

## GENERATE LEAF CERT - SERVER
#vault write -format=json pcf_int_n15/issue/server common_name="server.n15.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" > pcf_int_n15_server.cert.json
vault write -format=json \
    pcf_int_n15/issue/server \
    common_name="server.n15.bob.pcf.5gc.mnc88.mcc888.3gppnetwork.org" \
    | tee workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json

#    alt_names="server.n15.bob.pcf.5gc.mobilecarrier.net" \
#    uri_sans="server.n15.bob.pcf.5gc.mobilecarrier.net" \

## FORMAT LEAF CERT - SERVER
#touch workspace/tmp/pcf/server-n15/server.bundle
jq -r '.data.certificate' < workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json > workspace/tmp/pcf/server-n15/server.pem
jq -r '.data.certificate' < workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json > workspace/tmp/pcf/server-n15/server_chain.pem
jq -r '.data.ca_chain | join("\n")' < workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json >> workspace/tmp/pcf/server-n15/server_chain.pem
jq -r '.data.private_key' < workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json > workspace/tmp/pcf/server-n15/server_key.pem
jq -r '.data.issuing_ca' < workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json > workspace/tmp/pcf/server-n15/server_issuing_ca.pem
jq -r '.data.serial_number' < workspace/tmp/pcf/server-n15/pcf_int_n15_server.cert.json > workspace/tmp/pcf/server-n15/server.serial
##cp workspace/tmp/pcf/server-n15/server_chain.pem workspace/tmp/_archive/pcf/server/server_chain.pem.$(date +"%Y%m%d-%H%M%S").bak
#cat workspace/tmp/pcf/server-n15/server.pem workspace/tmp/pcf/server-n15/server_chain.pem > workspace/tmp/pcf/server-n15/server.bundle
#cat workspace/tmp/pcf/server-n15/server.bundle
