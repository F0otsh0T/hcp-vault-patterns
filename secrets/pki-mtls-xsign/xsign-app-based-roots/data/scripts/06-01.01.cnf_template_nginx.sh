#!/bin/sh

## 

set -e
set -x

## Nginx Configuration Template

#### One Service
echo '
server {
    listen REPLACELISTEN;
    listen REPLACETLSLISTEN ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /vault/secrets/server/server_chain.pem;
    ssl_certificate_key /vault/secrets/server/server_key.pem;
    
    ssl_client_certificate /vault/secrets/root.pem;
    
    ssl_verify_client on;
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

#### Two Services
echo '
server {
    listen REPLACELISTEN;
    listen REPLACETLSLISTEN ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /vault/secrets/server/server_chain.pem;
    ssl_certificate_key /vault/secrets/server/server_key.pem;
    
    ssl_client_certificate /vault/secrets/root.pem;
    
    ssl_verify_client on;
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

server {
    listen SUBLISTEN;
    listen SUBTLSLISTEN ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /vault/secrets/server/server_chain.pem;
    ssl_certificate_key /vault/secrets/server/server_key.pem;
    
    ssl_client_certificate /vault/secrets/root.pem;
    
    ssl_verify_client on;
    ssl_verify_depth 8;

    if ($ssl_client_verify != SUCCESS) {
        return 402;
    }

    location / {
        root   /usr/share/nginx/html;
#        index  index.html index.htm;
        index  TWOWWW.html TWOWWW.htm;
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
' > nginx-2svc.conf

## Format Template

#### AMF
sed 's/REPLACELISTEN/20080/g' nginx-1svc.conf \
    | sed 's/REPLACETLSLISTEN/20443/g' \
    | sed 's/ONEWWW/amf_n/g' \
    > workspace/tmp/amf/amf.conf

#### NEF
sed 's/REPLACELISTEN/21080/g' nginx-1svc.conf \
    | sed 's/REPLACETLSLISTEN/21443/g' \
    | sed 's/ONEWWW/nef_n/g' \
    > workspace/tmp/nef/nef.conf

#### PCF
sed 's/REPLACELISTEN/22080/g' nginx-2svc.conf \
    | sed 's/REPLACETLSLISTEN/22443/g' \
    | sed 's/SUBLISTEN/22081/g'  \
    | sed 's/SUBTLSLISTEN/22444/g' \
    | sed 's/ONEWWW/pcf_n7/g' \
    | sed 's/TWOWWW/pcf_n15/g' \
    > workspace/tmp/pcf/pcf.conf

### SMF
sed 's/REPLACELISTEN/23080/g' nginx-2svc.conf \
    | sed 's/REPLACETLSLISTEN/23443/g' \
    | sed 's/SUBLISTEN/23081/g'  \
    | sed 's/SUBTLSLISTEN/23444/g' \
    | sed 's/ONEWWW/smf_n11/g' \
    | sed 's/TWOWWW/smf_n29/g' \
    > workspace/tmp/smf/smf.conf
