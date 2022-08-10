#!/bin/sh

## 

set -e
set -x

## Nginx Configuration Template

#### Three Services
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

server {
    listen SUBTHREELISTEN;
    listen SUBTHREETLSLISTEN ssl;

    ssl_protocols TLSv1.2;

    ssl_certificate /vault/secrets/SUBTHREESVC/server_chain.pem;
    ssl_certificate_key /vault/secrets/SUBTHREESVC/server_key.pem;
    
    ssl_client_certificate /vault/secrets/SUBTHREEPEM.pem;
    
    ssl_verify_client on;
    ssl_verify_depth 8;

    if ($ssl_client_verify != SUCCESS) {
        return 402;
    }

    location / {
        root   /usr/share/nginx/html;
#        index  index.html index.htm;
        index  THREEWWW.html THREEWWW.htm;
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
' > nginx-3svc.conf

## Format Template

#### PCF
sed 's/SUBONELISTEN/22080/g' nginx-3svc.conf \
    | sed 's/SUBONETLSLISTEN/22443/g' \
    | sed 's/SUBTWOLISTEN/22081/g'  \
    | sed 's/SUBTWOTLSLISTEN/22444/g' \
    | sed 's/SUBTHREELISTEN/22082/g'  \
    | sed 's/SUBTHREETLSLISTEN/22445/g' \
    | sed 's/SUBONESVC/server/g' \
    | sed 's/SUBONEPEM/pcf_root/g' \
    | sed 's/SUBTWOSVC/server-n7/g' \
    | sed 's/SUBTWOPEM/pcf_root_n7/g' \
    | sed 's/SUBTHREESVC/server-n15/g' \
    | sed 's/SUBTHREEPEM/pcf_root_n15/g' \
    | sed 's/ONEWWW/pcf/g' \
    | sed 's/TWOWWW/pcf_n7/g' \
    | sed 's/THREEWWW/pcf_n15/g' \
    > workspace/tmp/pcf/pcf.conf

### SMF
sed 's/SUBONELISTEN/23080/g' nginx-3svc.conf \
    | sed 's/SUBONETLSLISTEN/23443/g' \
    | sed 's/SUBTWOLISTEN/23081/g'  \
    | sed 's/SUBTWOTLSLISTEN/23444/g' \
    | sed 's/SUBTHREELISTEN/23082/g'  \
    | sed 's/SUBTHREETLSLISTEN/23445/g' \
    | sed 's/SUBONESVC/server/g' \
    | sed 's/SUBONEPEM/smf_root/g' \
    | sed 's/SUBTWOSVC/server-n11/g' \
    | sed 's/SUBTWOPEM/smf_root_n11/g' \
    | sed 's/SUBTHREESVC/server-n29/g' \
    | sed 's/SUBTHREEPEM/smf_root_n29/g' \
    | sed 's/ONEWWW/smf/g' \
    | sed 's/TWOWWW/smf_n11/g' \
    | sed 's/THREEWWW/smf_n29/g' \
    > workspace/tmp/smf/smf.conf
