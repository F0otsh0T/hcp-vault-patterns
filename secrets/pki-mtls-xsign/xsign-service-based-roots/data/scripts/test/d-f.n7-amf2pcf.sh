#!/bin/sh

set -e
set -x

docker run -it mtlsxamf curl \
	-kv \
	--url https://192.168.65.2:22444 \
	--cert /vault/secrets/client-n15/client_chain.pem \
	--key /vault/secrets/client-n15/client_key.pem \
	--cacert /vault/secrets/amf_root.pem
