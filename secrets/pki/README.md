# VAULT SECRETS ENGINE: PKI

## INTRODUCTION

We will be utilizing some Open Source Software (OSS) tools like `make` to abstract and organize the steps for this demo and `PGP/GPG/PASS` to store and pass sensitive data like secrets ;-) This is an attempt to make this example modular, consumable, and the Client codified and immutable.

## PREREQUISITES

   - Docker
   - K3s / K3d
   - kubectl
   - Vault CLI
   - Terraform
   - make
   - jq
   - curl
   - PGP/GPG/PASS
   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,

## SHELL ENVIRONMENT

Depending on your Vault Application (K8s, Docker, HCP), you will need to set your shell `environment` variables for the following (E.g. @ `pki/env.sh`:

```shell
#!/bin/sh

set -o xtrace

## VAULT_SKIP_VERIFY
#export VAULT_SKIP_VERIFY=true
#unset VAULT_SKIP_VERIFY

## VAULT_TOKEN
#export VAULT_TOKEN=''
#unset VAULT_TOKEN

## VAULT_NAMESPACE: Vault Enterprise
#export VAULT_NAMESPACE=admin
#unset VAULT_NAMESPACE

## VAULT_ADDR
#export VAULT_ADDR='https://:8200'
#export VAULT_ADDR='https://CHANGE_ME.aws.hashicorp.cloud:8200'
#export VAULT_ADDR='http://0.0.0.0:8200'
#export VAULT_ADDR='https://0.0.0.0:8200'
#export VAULT_ADDR='http://127.0.0.1:8200'
#export VAULT_ADDR='https://127.0.0.1:8200'
#export VAULT_ADDR='https://127.0.0.1:8201'
#export VAULT_ADDR='https://:8200'
#unset VAULT_ADDR

## VAULT_FORMAT
#export VAULT_FORMAT=json
#unset VAULT_FORMAT

## VAULT_TOKEN
#export VAULT_TOKEN=$(pass vault/pki_test)
#unset VAULT_TOKEN
```
**OR**
```shell
export VAULT_ADDR=$(pass vault/local-url)
export VAULT_TOKEN=$(pass vault/local-token)
unset VAULT_NAMESPACE
```
```shell
export VAULT_ADDR=$(pass vault/hcp-url)
export VAULT_TOKEN=$(pass vault/hcp-token)
export VAULT_NAMESPACE=admin
```

^^ Note: `GPG/PGP/Pass` locations above depends on where you have stored your local Secrets - This is just a little tidiness to keep the credentials from being stored in shell history

Utilizing `GPG/PGP/Pass` to store and pass sensitive information throughout this demo. `Makefiles` will be utilized to organize and run the steps from the `pki` (most of the VAULT PKI activity) and `pki/workspace` (Docker Build & Run activity) directories. The above VAULT environment variables will be important to set properly for this demo to function.

## VAULT

You can spin up a Vault environment via a number of different ways:
- Hashicorp Cloud Platform (HCP): https://learn.hashicorp.com/collections/vault/cloud
- Install binaries: https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
- Docker: https://github.com/F0otsh0T/hcp-vault-docker

## OPTIONAL: CREATE POLICY

```shell
cd pki
make -f 01-01.cli.policy.make create-policy
vault policy list | jq
```

## OPTIONAL: CREATE NEW AUTH TOKEN WITH ABOVE POLICY

```shell
make -f 01-02.cli.auth_token.make auth-token
make -f 01-02.cli.auth_token.make vault-login
vault token lookup -format=json | jq
```

## VAULT: PKI ENGINE - CA ROOT

```shell
make -f 02-01.cli.pki.make pki-enable
make -f 02-01.cli.pki.make pki-ca_root_create
make -f 02-01.cli.pki.make pki-ca_crl
```

## VAULT: PKI_INT ENGINE - INTERMEDIATE CA

```shell
make -f 02-02.cli.pki_int.make pki_int-enable
make -f 02-02.cli.pki_int.make pki_int-csr
make -f 02-02.cli.pki_int.make pki_int-csr_sign
make -f 02-02.cli.pki_int.make pki_int-cert_import
make -f 02-02.cli.pki_int.make pki_int-ca_crl
make -f 02-02.cli.pki_int.make pki_int-role_create
```

## VAULT: CREATE INTERMEDIATE CERTIFICATE

```shell
make -f 03-01.cli.intermediate_create.make cert-create
make -f 03-01.cli.intermediate_create.make cert-format
make -f 03-01.cli.intermediate_create.make cert-list
make -f 03-01.cli.intermediate_create.make cert-read
```

## VAULT CLIENT: NGINX - BUILD IMAGE

"IMMUTABLE": We will build the PKI data into the container for this demo but other methods exist to inject or consume PKI into the service:
- Vault Agent Inject / Sidecar (`mutatingwebhook`)
- K8s `configmap`
- certmanager
- Container volume mounts / CSI (K8s Container Storage Interface)
- etc.,

```shell
cd pki/workspace
make -f Makefile build
docker image ls | grep -i pkiclient
```

## VAULT CLIENT: NGINX - RUN

```shell
terraform init
terraform plan
terraform apply
```
^^ Input "yes"

```shell
docker ps | grep -i pkiclient
```

## WEB BROWSER TEST

Open up your web browser and open up the web page @:
- https://127.0.0.1:9000
- `CN` URL as declared in the Intermediate Certificate create process - you may need to create a host entry to point to the IP of where the Docker service for Nginx resides.
- Import `CA` Cert as "TRUSTED" in your Web Browser

