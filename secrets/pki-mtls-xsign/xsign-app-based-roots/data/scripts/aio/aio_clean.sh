#!/bin/sh
# Alex Scheel

docker stop mtlsx_carol_amf
docker stop mtlsx_alice_smf
docker stop mtlsx_bob_pcf

docker rm mtlsx_carol_amf
docker rm mtlsx_alice_smf
docker rm mtlsx_bob_pcf

vault secrets disable pki_root_amf
vault secrets disable pki_int_amf
vault secrets disable pki_root_smf
vault secrets disable pki_int_smf
vault secrets disable pki_root_pcf
vault secrets disable pki_int_pcf

rm *pem
rm *json
rm *html
rm *Containerfile
rm *config
rm *template
