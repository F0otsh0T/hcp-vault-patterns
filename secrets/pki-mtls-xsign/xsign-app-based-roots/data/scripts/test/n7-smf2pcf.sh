#!/bin/sh

set -e
set -x

curl \
	-kv \
	--url https://127.0.0.1:22443 \
	--cert workspace/tmp/smf/n7/client_chain.pem \
	--key workspace/tmp/smf/n7/client_key.pem \
	--cacert workspace/tmp/smf/root.pem
