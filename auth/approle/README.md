# VAULT / AUTH - AppRole (Pull)

"Before a client can interact with Vault, it must authenticate against an auth method to acquire a token. This token has policies attached so that the behavior of the client can be governed."

[![High Level Flow - Auth Method](https://mktg-content-api-hashicorp.vercel.app/api/assets?product=tutorials&version=main&asset=public%2Fimg%2Fvault-auth-basic-2.png)](https://learn.hashicorp.com/tutorials/vault/approle)

https://learn.hashicorp.com/tutorials/vault/approle

The **[AppRole](https://www.vaultproject.io/docs/auth/approle)** ```auth``` method is an authentication mechanism within **Vault** to allow machines or apps to acquire a token to interact with Vault. It uses **RoleID** and **SecretID** for login.

## PREREQUISITES

   - Docker
   - Kubernetes (K3s / K3d)
   - kubectl
   - Vault CLI
   - Terraform
   - make
   - jq
   - curl
   - PGP/GPG/PASS
   - Vault **[Initialized & Unsealed](https://learn.hashicorp.com/tutorials/vault/getting-started-deploy)**

## Personas

The end-to-end scenario described in this tutorial involves two (or three) personas:

- ```admin``` with privileged permissions to configure an auth method
- ```trusted entity``` delivers the RoleID and SecretID to the client by separate means (this could also be ```admin```)
- ```app``` is the consumer of secrets stored in Vault

## Steps

#### KV2 Secrets Engine

KV2 Secrets Engine enabled and populated in this step will be retrieved via **Persona**: ```app``` later with access ```token``` harvested from **AppRole** ```auth```.

```shell
vault secrets enable -version=2 -path=nginx kv
Success! Enabled the kv secrets engine at: secret/data/nginx/

vault kv put -format=json nginx/secret foo=bar | jq
{
  "request_id": "7e98faad-4e5e-fca9-d799-11750ba1bf5a",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "created_time": "2022-06-21T06:05:13.036303634Z",
    "custom_metadata": null,
    "deletion_time": "",
    "destroyed": false,
    "version": 1
  },
  "warnings": null
}

vault kv get -format=json  nginx/secret | jq
{
  "request_id": "275fdc50-5c3a-74c2-f0d5-6add3cf2a4e5",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "data": {
      "foo": "bar"
    },
    "metadata": {
      "created_time": "2022-06-21T06:05:13.036303634Z",
      "custom_metadata": null,
      "deletion_time": "",
      "destroyed": false,
      "version": 2
    }
  },
  "warnings": null
}

```

#### Enable AppRole Auth Method
> **Persona**: ```admin```

- CLI:
   ```shell
   vault auth enable approle
   Success! Enabled approle auth method at: approle/
   ```
- API:
   ```shell
   curl --header "X-Vault-Token: $VAULT_TOKEN" \
      --request POST \
      --data '{"type": "approle"}' \
      $VAULT_ADDR/v1/sys/auth/approle
   ```
   JSON:
   ```json
   {
      "type": "approle"
   }
   ```

#### Create Vault Policy
This **Vault** ```policy``` will be applied to the ```role``` 

> **Persona**: ```admin```

Before creating a role, create a **nginx** ```policy``` (file located in this directory @ ```policy-approle.hcl```)
```shell
vault policy write nginx policy-approle.hcl
Success! Uploaded policy: nginx

vault policy read nginx
# Mount the AppRole auth method
path "sys/auth/approle" {
capabilities = [ "create", "read", "update", "delete", "sudo" ]
}

# Configure the AppRole auth method
path "sys/auth/approle/*" {
capabilities = [ "create", "read", "update", "delete" ]
}

# Create and manage roles
path "auth/approle/*" {
capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Write ACL policies
path "sys/policies/acl/*" {
capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Write test data
# Set the path to "secret/data/mysql/*" if you are running `kv-v2`
path "secret/nginx/*" {
capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "secret/data/nginx/*" {
capabilities = [ "create", "read", "update", "delete", "list" ]
}
```

#### Create AppRole Role

> **Persona**: ```admin```

Create **AppRole** ```role``` named **nginx** with ```policy``` named **nginx** applied. The generated token's time-to-live (TTL) is set to 1 hour and can be renewed for up to 4 hours of its first creation.
> NOTE: This example creates a role which operates in **[pull mode](https://www.vaultproject.io/docs/auth/approle.html)**.
```shell
vault write auth/approle/role/nginx token_policies="nginx" \
   token_ttl=1h \
   token_max_ttl=4h
Success! Data written to: auth/approle/role/nginx

vault read auth/approle/role/nginx -format=json | jq
{
  "request_id": "ca0c63e6-c55e-82e0-f621-ac7d22ec77d2",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "bind_secret_id": true,
    "local_secret_ids": false,
    "secret_id_bound_cidrs": null,
    "secret_id_num_uses": 0,
    "secret_id_ttl": 0,
    "token_bound_cidrs": [],
    "token_explicit_max_ttl": 0,
    "token_max_ttl": 14400,
    "token_no_default_policy": false,
    "token_num_uses": 0,
    "token_period": 0,
    "token_policies": [
      "nginx"
    ],
    "token_ttl": 3600,
    "token_type": "default"
  },
  "warnings": null
}
```
**AppRole** ```role``` parameters @ https://www.vaultproject.io/api-docs/auth/approle#parameters

If you want to limit the use of the generated secret ID, set secret_id_num_uses or secret_id_ttl parameter values. Similarly, you can specify token_num_uses and token_ttl. You may never want the app token to expire. In such a case, specify the period so that the token generated by this AppRole is a periodic token. To learn more about periodic tokens, refer to the Tokens tutorial.

#### Get ==*RoleID*== & ==*SecretID*==

> **Persona**: ```trusted entity``` or ```admin```

The ==***RoleID***== and ==***SecretID***== are like a **username** and **password** that a machine or app uses to authenticate.

Since the example created a **nginx** ```role``` which operates in **pull mode**, **Vault** will generate the ***SecretID***. You can set properties such as usage-limit, TTLs, and expirations on the ***SecretIDs*** to control its lifecycle.

- Get ==***RoleID***== @ ```auth/approle/role/<ROLE_NAME>/role-id``` endpoint
   ```shell
   vault read -format=json auth/approle/role/nginx/role-id | jq > role-id.json

   cat role-id.json
   {
   "request_id": "7baa359d-0fe9-9e8d-08f4-d1787047026b",
   "lease_id": "",
   "lease_duration": 0,
   "renewable": false,
   "data": {
      "role_id": "451290fd-c1b9-98b5-2877-f88b3890427b"
   },
   "warnings": null
   }
   ```
- Generate new  ==***SecretID***== @ ```auth/approle/role/<ROLE_NAME>/secret-id``` endpoint
   ```shell
   vault write -format=json -force auth/approle/role/nginx/secret-id | jq > secret-id.json

   cat secret-id.json
   vault write -format=json -force auth/approle/role/nginx/secret-id | jq > secret-id.json

   cat secret-id.json
   {
   "request_id": "87f4ad9d-d1a7-c7fe-afad-d6429e9e4afb",
   "lease_id": "",
   "lease_duration": 0,
   "renewable": false,
   "data": {
      "secret_id": "e15893d0-e067-a75c-4055-1ac5dd286cb3",
      "secret_id_accessor": "57b4eaf7-97bf-83fe-bb0e-7b7222629ad1",
      "secret_id_ttl": 0
   },
   "warnings": null
   }
   ```
- Set environment variables from above outputs
   ```shell
   export roleid=$(cat role-id.json | jq -r .data.role_id)

   export secretid=$(cat secret-id.json | jq -r .data.secret_id)
   ```

#### Login with ==***RoleID***== & ==***SecretID***== to get ```token```

> **Persona**: ```app```

The client (in this case, **NGINX** uses the ==***RoleID***== and ==***SecretID***== passed by the ```admin``` to authenticate with **Vault**. Once authenticated, **Vault** will return the access ```token```

To login, use the ```auth/approle/login``` endpoint by passing the ==***RoleID***== and ==***SecretID***==.

- CLI:
   ```shell
   vault write -format=json auth/approle/login role_id="Loremips-umdo-lors-itam-etconsectetu" \
      secret_id="radipisc-inge-litE-xpec-toquequidadi" \
      jq -r ".auth" > client_token.json

   cat client_token.json
   {
   "client_token": "s.Loremipsumdolorsitametco",
   "accessor": "nsecteturadipiscingelitE",
   "policies": [
      "default",
      "nginx"
   ],
   "token_policies": [
      "default",
      "nginx"
   ],
   "identity_policies": null,
   "metadata": {
      "role_name": "nginx"
   },
   "orphan": true,
   "entity_id": "1de3bf51-cc4d-e58b-3d34-b96674785417",
   "lease_duration": 3600,
   "renewable": true,
   "mfa_requirement": null
   }
   ```
- API:
   ```shell
   curl --request POST --data '{ "role_id": ""$roleid"", "secret_id": ""$secretid"" }' $VAULT_ADDR/v1/auth/approle/login \
      | jq -r ".auth" > client_token.json
   ```
  API / Payload:
   ```shell
   curl --request POST --data @payload.json $VAULT_ADDR/v1/auth/approle/login \
      | jq -r ".auth" > client_token.json

   ```
   JSON:
   ```json
   {
   "role_id": "Loremips-umdo-lors-itam-etconsectetu",
   "secret_id": "radipisc-inge-litE-xpec-toquequidadi"
   }
   ```

#### Read Secret with AppRole Supplied Client Token

> **PERSONA**: ```app```
> 

```shell
VAULT_TOKEN=$(jq -r .client_token < client_token.json) vault kv get nginx/secret
== Secret Path ==
nginx/data/secret

======= Metadata =======
Key                Value
---                -----
created_time       2022-06-21T23:16:20.961653501Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

=== Data ===
Key    Value
---    -----
foo    bar
```
## Makefile

In this directoy, you'll find a ```Makefile``` that has each of the steps documented above as ***#target***'s to be executed against:

- **clean**: #target
- **all**: vault-policy vault-secrets-enable-kv2 auth-approle-enable auth-approle-write-role auth-approle-get-roleid auth-approle-get-secretid auth-approle-get-token #target
- **vault-policy**: #target
- **vault-secrets-enable-kv2**: #target
- **auth-approle-enable**: #target
- **auth-approle-enable-api**: #target
- **auth-approle-write-role**: #target
- **auth-approle-get-roleid**: #target
- **auth-approle-get-secretid**: #target
- **auth-approle-get-token**: #target
- **auth-approle-read-secret**: #target

To run all the steps at once:
```shell
make -f Makefile all
```

Otherwise, you can execute each ***#target*** sequentially if you wish. Also, see [GitHub User @jacobm3](https://github.com/jacobm3)'s shell scripts that perform a similar sequence referenced in the [References](#references) section below.

## References

- https://www.vaultproject.io/docs/auth/approle
- https://learn.hashicorp.com/tutorials/vault/approle-best-practices
- https://learn.hashicorp.com/tutorials/vault/approle
- https://www.hashicorp.com/blog/how-and-why-to-use-approle-correctly-in-hashicorp-vault
- https://github.com/jacobm3/vault-local-demo/tree/main/approle-diy-rotate
- https://github.com/jacobm3/vault-local-demo/tree/main/approle-rotate-self
























## Appendix

###### Advanced Distribution of ==***RoleID***== & ==***SecretID***==

- https://learn.hashicorp.com/tutorials/vault/approle#response-wrap-the-secretid

[Login with RoleID & SecretID to get Token](#login-with-roleid--secretid-to-get-token)