#!/bin/sh

set -e
set -x

docker run -it mtlsxnef curl \
	-kv \
	--url https://192.168.65.2:22444 \
	--cert /vault/secrets/client-n29/client_chain.pem \
	--key /vault/secrets/client-n29/client_key.pem \
	--cacert /vault/secrets/nef_root.pem
