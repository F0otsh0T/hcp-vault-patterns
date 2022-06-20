# VAULT / AUTH - JWT - OIDC: Public Key Validation

This method can be useful if Kubernetes' API is not reachable from Vault or if you would like a single JWT auth mount to service multiple Kubernetes clusters by chaining their public signing keys.

https://www.vaultproject.io/docs/auth/jwt/oidc_providers#using-jwt-validation-public-keys

## PREREQUISITES

   - Docker
   - Kubernetes (K3s / K3d)
   - K8s [ServiceAccountIssuerDiscovery](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery) feature enabled
   - kubectl
   - Vault CLI
   - Terraform
   - make
   - jq
   - curl
   - PGP/GPG/PASS
   - Vault PKI Engines, Auth, Policies, Certs, Roles, etc.,

## Spin up a Kubernetes Cluster

Via **Terraform**:

https://github.com/F0otsh0T/hcp-vault-docker/tree/main/01-k3d

Manually via **Shell**:

```shell
k3d cluster create --agents 2 --k3s-arg "--tls-san=192.168.65.2"@server:* auth-jwt-pki
```
```192.168.65.2``` is ```host.docker.internal``` (and ```host.k3d.internal``` in our environment with **K3d**) with an overlay ```IP``` for host node ```127.0.0.1``` or ```0.0.0.0```

## Configuration Steps

1. Fetch the service account signing public key from your cluster's JWKS URI.
   > Note: This requirement can be avoided if you can access the Kubernetes master nodes to read the public signing key directly from disk at /etc/kubernetes/pki/sa.pub. In this case, you can skip the steps to retrieve and then convert the key as it will already be in PEM format.
    - Find the ```issuer``` URL for the Kubernetes Cluster
      ```shell
      export ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"

      echo $ISSUER
      https://kubernetes.default.svc.cluster.local
      ```
    - Query the jwks_uri specified in /.well-known/openid-configuration
      ```shell
      kubectl get --raw "$(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri' | sed -r 's/.*\.[^/]+(.*)/\1/')" | jq -r '.keys[]'
      {
      "use": "sig",
      "kty": "RSA",
      "kid": "-IeWPXFbKw-sNfOX18TuIzLr6fr2sXjWEbU-okW7fz4",
      "alg": "RS256",
      "n": "LoremipsumdolorsitametconsecteturadipiscingelitExpectoquequidadidquodquaerebamrespondeasProfectusinexiliumTubulusstatimnecrespondereaususDuoRegesconstructiointerreteHicnihilfuitquodquaereremusSedilleutdixivitioseNonautemhocigiturneilludquidemAgeinquiesistaparvasuntQuemTiberinadescensiofestoillodietantogaudioaffecitquantoLSemperenimitaadsumitaliquiduteaquaeprimadederitnondeseratQuarumambarumrerumcummedicinampolliceturluxu",
      "e": "AQAB"
      }
      ```
2. Convert the keys from JWK format to PEM. You can use a CLI tool or an online converter such as **[this one](https://8gwifi.org/jwkconvertfunctions.jsp)**.
3. Enable and configure JWT auth in **Vault**
   ```shell
   vault auth enable jwt
   Success! Enabled jwt auth method at: jwt/
   ```
4. Configure the **JWT** Auth mount with those public keys.
   ```shell
   vault write auth/jwt/config \
      jwt_validation_pubkeys="-----BEGIN PUBLIC KEY-----
   LoremipsumdolorsitametconsecteturadipiscingelitExpectoquequidadid
   quodquaerebamrespondeasProfectusinexiliumTubulusstatimnecresponde
   reaususDuoRegesconstructiointerreteHicnihilfuitquodquaereremusSed
   illeutdixivitioseNonautemhocigiturneilludquidemAgeinquiesistaparv
   asuntQuemTiberinadescensiofestoillodietantogaudioaffecitquantoLSe
   mperenimitaadsumitaliquiduteaquaeprimadederitnondeseratQuarumamba
   rumrerum
   -----END PUBLIC KEY-----"
   Success! Data written to: auth/jwt/config

   vault read auth/jwt/config
   Key                       Value
   ---                       -----
   bound_issuer              n/a
   default_role              n/a
   jwks_ca_pem               n/a
   jwks_url                  n/a
   jwt_supported_algs        []
   jwt_validation_pubkeys    [-----BEGIN PUBLIC KEY-----
   LoremipsumdolorsitametconsecteturadipiscingelitExpectoquequidadid
   quodquaerebamrespondeasProfectusinexiliumTubulusstatimnecresponde
   reaususDuoRegesconstructiointerreteHicnihilfuitquodquaereremusSed
   illeutdixivitioseNonautemhocigiturneilludquidemAgeinquiesistaparv
   asuntQuemTiberinadescensiofestoillodietantogaudioaffecitquantoLSe
   mperenimitaadsumitaliquiduteaquaeprimadederitnondeseratQuarumamba
   rumrerum
   -----END PUBLIC KEY-----]
   namespace_in_state        true
   oidc_client_id            n/a
   oidc_discovery_ca_pem     n/a
   oidc_discovery_url        n/a
   oidc_response_mode        n/a
   oidc_response_types       []
   provider_config           map[]
   ```
5. ^^ **JWT** Auth mount is configured. Ready to configure a role.
   ```shell
   vault write auth/jwt/role/my-role \
      role_type="jwt" \
      bound_audiences="${ISSUER}" \
      user_claim="sub" \
      bound_subject="system:serviceaccount:default:default" \
      policies="default" \
      ttl="1h"

   vault read auth/jwt/role/my-role
   Key                        Value
   ---                        -----
   allowed_redirect_uris      <nil>
   bound_audiences            [https://kubernetes.default.svc.cluster.local]
   bound_claims               <nil>
   bound_claims_type          string
   bound_subject              system:serviceaccount:default:default
   claim_mappings             <nil>
   clock_skew_leeway          0
   expiration_leeway          0
   groups_claim               n/a
   max_age                    0
   not_before_leeway          0
   oidc_scopes                <nil>
   policies                   [default]
   role_type                  jwt
   token_bound_cidrs          []
   token_explicit_max_ttl     0s
   token_max_ttl              0s
   token_no_default_policy    false
   token_num_uses             0
   token_period               0s
   token_policies             [default]
   token_ttl                  1h
   token_type                 default
   ttl                        1h
   user_claim                 sub
   verbose_oidc_logging       false
   ```
6. Log in via **JWT** Auth Method Role to retrieve access **token**
    - Create NGINX K8s ```deployment``` 
      ```shell
      kubectl create deployment nginx --image=nginx
      deployment.apps/nginx created
      ```
    - Create NGINX K8s ```service```
      ```shell
      kubectl create service nodeport nginx --tcp=80:80
      service/nginx created
      ```
    - Exec into the Pod and attempt to Log into **Vault** via ```curl```
      ```shell
      export VAULT_ADDR=http://192.168.65.2:8200

      export JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

      curl \
         --fail \
         --request POST \
         --header "X-Vault-Request: true" \
         --data '{"jwt":"'"${JWT}"'","role":"my-role"}' \
         "${VAULT_ADDR}/v1/auth/jwt/login"
      {
      "request_id": "129e8219-f7da-56fc-12f5-15eea3d36ab6",
      "lease_id": "",
      "renewable": false,
      "lease_duration": 0,
      "data": null,
      "wrap_info": null,
      "warnings": null,
      "auth": {
         "client_token": "s.Loremipsumdolorsitametco",
         "accessor": "Loremipsumdolorsitametco",
         "policies": [
            "default"
         ],
         "token_policies": [
            "default"
         ],
         "metadata": {
            "role": "my-role"
         },
         "lease_duration": 3600,
         "renewable": true,
         "entity_id": "87f06d06-b560-fb3d-0d77-3b40fe0431d7",
         "token_type": "service",
         "orphan": true
      }
      }

      ```

      ^^ ```client_token``` aquired

    - Alternatively if you have **Vault** CLI installed:
      ```shell
      vault write auth/jwt/login \
      role=my-role \
      jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token
      ```



## Reference
- https://www.vaultproject.io/docs/auth/jwt
- https://www.vaultproject.io/docs/auth/jwt/oidc_providers#using-jwt-validation-public-keys
-  https://learn.hashicorp.com/tutorials/vault/agent-kubernetes#create-a-service-account
- https://www.vaultproject.io/docs/platform/k8s/injector
- https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar

## Appendix

```shell
curl \
   --fail \
   --request POST \
   --header "X-Vault-Request: true" \
   --data "{\"jwt\":\"$(cat /var/run/secrets/kubernetes.io/serviceaccount/token )\",\"role\":\"my-role\"}" \
   "${VAULT_ADDR}/v1/auth/jwt/login"
```

```shell
curl \
   --fail \
   --request POST \
   --header "X-Vault-Request: true" \
   --data "{\"jwt\":\"${JWT}\",\"role\":\"my-role\"}" \
   "${VAULT_ADDR}/v1/auth/jwt/login"
```

JSON Body
```json
{
    "jwt":"$JWT",
    "role":"my-role"
}
```

CURL Request
```shell
curl \
   --fail \
   --request POST \
   --header "X-Vault-Request: true" \
   --data @body \
   "${VAULT_ADDR}/v1/auth/jwt/login"
```