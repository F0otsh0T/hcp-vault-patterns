#!/bin/sh

## 

set -e
set -x

## Nginx Configuration Template

#### Two Services
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

server {
    listen SUBTWOLISTEN;
    listen SUBTWOTLSLISTEN ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /vault/secrets/SUBTWOSVC/server_chain.pem;
    ssl_certificate_key /vault/secrets/SUBTWOSVC/server_key.pem;
    
    ssl_client_certificate /vault/secrets/SUBTWOPEM.pem;
    
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

#### CHANGEME1
#sed 's/SUBONELISTEN/80/g' nginx-2svc.conf \
#    | sed 's/SUBONETLSLISTEN/443/g' \
#    | sed 's/SUBTWOLISTEN//g'  \
#    | sed 's/SUBTWOTLSLISTEN//g' \
#    | sed 's/SUBONESVC//g' \
#    | sed 's/SUBONEPEM//g' \
#    | sed 's/SUBTWOSVC//g' \
#    | sed 's/SUBTWOPEM//g' \
#    | sed 's/ONEWWW//g' \
#    | sed 's/TWOWWW//g' \
#    > workspace/tmp/changeme1/changeme1.conf

#### CHANGEME2
#sed 's/SUBONELISTEN/80/g' nginx-2svc.conf \
#    | sed 's/SUBONETLSLISTEN/443/g' \
#    | sed 's/SUBTWOLISTEN//g'  \
#    | sed 's/SUBTWOTLSLISTEN//g' \
#    | sed 's/SUBONESVC//g' \
#    | sed 's/SUBONEPEM//g' \
#    | sed 's/SUBTWOSVC//g' \
#    | sed 's/SUBTWOPEM//g' \
#    | sed 's/ONEWWW//g' \
#    | sed 's/TWOWWW//g' \
#    > workspace/tmp/changeme1/changeme2.conf
