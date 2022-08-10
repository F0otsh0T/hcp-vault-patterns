#!/bin/sh

## 

set -e
set -x

## Nginx Configuration Template

#### One Service
echo '
server {
    listen SUBONELISTEN;
    listen SUBONETLSLISTEN ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /vault/secrets/SUBONESVC/server_chain.pem;
    ssl_certificate_key /vault/secrets/SUBONESVC/server_key.pem;
    
    ssl_client_certificate /vault/secrets/SUBONEPEM.pem;
    
    ssl_verify_client off;
    ssl_verify_depth 8;

    if ($ssl_client_verify != SUCCESS) {
        return 402;
    }

    location / {
        root   /usr/share/nginx/html;
#        index  index.html index.htm;
        index  ONEWWW.html ONEWWW.htm;
        autoindex on;

        if ($ssl_client_verify != SUCCESS) {
                return 403;
        }
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
' > nginx-1svc.conf

## Format Template

#### AMF
sed 's/SUBONELISTEN/20080/g' nginx-1svc.conf \
    | sed 's/SUBONETLSLISTEN/20443/g' \
    | sed 's/SUBONESVC/server/g' \
    | sed 's/SUBONEPEM/amf_root/g' \
    | sed 's/ONEWWW/amf/g' \
    > workspace/tmp/amf/amf.conf

#### NEF
sed 's/SUBONELISTEN/21080/g' nginx-1svc.conf \
    | sed 's/SUBONETLSLISTEN/21443/g' \
    | sed 's/SUBONESVC/server/g' \
    | sed 's/SUBONEPEM/nef_root/g' \
    | sed 's/ONEWWW/nef/g' \
    > workspace/tmp/nef/nef.conf


