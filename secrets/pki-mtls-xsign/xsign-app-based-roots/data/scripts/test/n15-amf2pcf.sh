#!/bin/sh

set -e
set -x

curl \
	-kv \
	--url https://127.0.0.1:22444 \
	--cert workspace/tmp/amf/n15/client_chain.pem \
	--key workspace/tmp/amf/n15/client_key.pem \
	--cacert workspace/tmp/amf/root.pem
