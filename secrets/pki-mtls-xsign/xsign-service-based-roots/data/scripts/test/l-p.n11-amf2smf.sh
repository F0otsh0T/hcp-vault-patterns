#!/bin/sh

set -e
set -x

curl \
	-kv \
	--url https://127.0.0.1:23444 \
	--cert workspace/tmp/amf/client-n11/client_chain.pem \
	--key workspace/tmp/amf/client-n11/client_key.pem \
	--cacert workspace/tmp/amf/amf_root.pem
