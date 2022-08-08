#!/bin/sh

set -e
set -x

curl \
	-kv \
	--url https://127.0.0.1:23444 \
	--cert workspace/tmp/nef/n29/client_chain.pem \
	--key workspace/tmp/nef/n29/client_key.pem \
	--cacert workspace/tmp/nef/root.pem
