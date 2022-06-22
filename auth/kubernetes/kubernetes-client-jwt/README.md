# VAULT / AUTH - Kubernetes Vault Client JWT

"Before a client can interact with Vault, it must authenticate against an auth method to acquire a token. This token has policies attached so that the behavior of the client can be governed."

[![High Level Flow - Auth Method](https://mktg-content-api-hashicorp.vercel.app/api/assets?product=tutorials&version=main&asset=public%2Fimg%2Fvault-auth-basic-2.png)](https://www.vaultproject.io/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt)

- https://www.vaultproject.io/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt

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

External Vault Service should exist ***a priori*** ( e.g. ***[HERE](https://github.com/F0otsh0T/hcp-vault-docker/tree/main/00-vault)*** )

## Notes

- If you are running **Kubernetes v1.21+**, ensure the config option disable_iss_validation is set to true. Assuming the default mount path, you can check with vault read -field disable_iss_validation auth/kubernetes/config. See [***Kubernetes 1.21***](https://www.vaultproject.io/docs/auth/kubernetes#kubernetes-1-21) notes for more details.
- Also, given **Kubernetes v1.21+** short-lived tokens, the options of how to work with these are listed [***HERE***](https://www.vaultproject.io/docs/auth/kubernetes#how-to-work-with-short-lived-kubernetes-tokens). For the purpose of this excercise, we will be using Option #2 ([***Use client JWT as reviewer JWT***](https://www.vaultproject.io/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt))
- Network Connectivity:
  - **K8s** Application => **Vault API** (:8200)
  - **Vault K8s Auth Engine** => **Kubernetes API** (:6443)

## Spin up a Kubernetes Cluster

Via **Terraform**:

https://github.com/F0otsh0T/hcp-vault-docker/tree/main/01-k3d

Manually via **Shell**:

```shell
k3d cluster create --agents 2 --k3s-arg "--tls-san=192.168.65.2"@server:* auth-jwt-pki
```
```192.168.65.2``` is ```host.docker.internal``` (and ```host.k3d.internal``` in our environment with **K3d**) with an overlay ```IP``` for host node ```127.0.0.1``` or ```0.0.0.0```

## [Kubernetes] Resources

This section is pulled from the HashiCorp documentation here:
https://learn.hashicorp.com/tutorials/vault/agent-kubernetes#create-a-service-account


- **clusterrolebinding**: ```role-tokenreview-binding```
- **serviceaccount**: ```vault-auth```

###### 1. Create K8s Resources
- Create a ```serviceaccount```

    Create a Kubernetes **serviceaccount** named ```vault-auth```

    ```shell
    kubectl create serviceaccount vault-auth
    ```

- Define ```clusterrolebinding```

    Create a Kubernetes **clusterrolebinding** resource with **clusterrole** of ```system:auth-delegator``` so that it applies that spec to the client of Vault (via **serviceaccount** <= **clusterrolebinding** <= **clusterrole**).

    Use the following **YAML manifest** as an example to create the **clusterrolebinding** resource with filename == ```vault-auth-service-account.yaml```:

    ```yaml
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
    name: role-tokenreview-binding
    namespace: default
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: system:auth-delegator
    subjects:
    - kind: ServiceAccount
    name: vault-auth
    namespace: default
    ```

- Apply ```clusterrolebinding``` manifest to update the ```vault-auth``` ```serviceaccount```

    ```shell
    kubectl apply -f vault-auth-service-account.yaml
    ```

###### 2. Harvesting Data Needed from K8s Resources
- ```VAULT_SA_NAME```
    From the **serviceaccount** ```vault-auth```, we need to extract the data value from the **.secrets[*]['name']** location to further harvest data from for our **Vault K8s Auth Method**
    ```shell
    $ kubectl get sa vault-auth -o json
    {
        "apiVersion": "v1",
        "kind": "ServiceAccount",
        "metadata": {
            "creationTimestamp": "2022-06-03T02:25:53Z",
            "name": "vault-auth",
            "namespace": "default",
            "resourceVersion": "3513",
            "uid": "831404c9-06ca-4e38-b59e-d5f6bf76579a"
        },
        "secrets": [
            {
                "name": "vault-auth-token-8spcq"
            }
        ]
    }

    $ k get sa vault-auth -o json | jq -r '.secrets[0].name'
    vault-auth-token-8spcq

    $ k get sa vault-auth -o json | jq -r '.secrets[].name'
    vault-auth-token-8spcq

    $ kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}"
    vault-auth-token-8spcq
    ```
    In this case, we are looking for that ```vault-auth-token-8spcq``` value. Another way to extract this and set the environment variable at the same time is:
    ```shell
    $ export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
    vault-auth-token-8spcq
    $ echo $VAULT_SA_NAME
    vault-auth-token-8spcq
    ```
- ```SA_JWT_TOKEN``` (BASE64 DECODE)
    Set the **serviceaccount** JWT (embedded in the ***serviceaccount** resource's **secret**) as an environment variable ```SA_JWT_TOKEN```. This will be used by **Vault K8s Auth Method** to access the Kubernetes Cluster **TokenReview** API.
    ```shell
    $ export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME --output 'go-template={{ .data.token }}' | base64 --decode)
    $ echo $SA_JWT_TOKEN
    BLAHBLAHBLAHJWT
    ```
- ```SA_CA_CRT``` (BASE64 DECODE)
    Set the **certificate** environment variable ```SA_CA_CRT``` for the Kubernetes Cluster from the **.clusters[].cluster.certificate-authority-data** (PEM Encoded Cluster CA CRT) that will be used by **Vault K8s Auth Method** to access this Cluster's **Kubernetes API**
    ```shell
    $ export SA_CA_CRT=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
    $ echo $SA_CA_CRT
    -----BEGIN CERTIFICATE-----
    BLAHBLAHBLAHCERTIFICATE
    -----END CERTIFICATE-----
    ```
- ```K8S_HOST```
    Set environment variable ```K8S_HOST``` for the **Kubernetes API** ```URL``` so that **Vault** can know how to reach the **K8s** Cluster.
    ```shell
    $ export K8S_HOST=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')
    $ echo $K8S_HOST
    https://blah.blah:53682
    ```
    **OR** via ```jq```
    ```shell
    export K8S_HOST=$(kubectl config view --raw --minify --flatten -o json | jq -r '.clusters[].cluster.server'
    $ echo $K8S_HOST
    https://blah.blah:53682
    ```
    > NOTE: From **Vault**'s perspective, this network path must be reachable as it is attempting to contact the **Kubernetes API**. The output from the above command from the **K8s** cluster's perspective may or may not match up exactly with **Vault**'s view of the network.
    >
    > In this case, because **Vault** is running in the same Docker Runtime environment as the **K8s** Cluster, probably need to understand the ```ip``` that will get you to the **HOST** IP point of presence (*host.docker.internal* or *host.k3d.internal* @ 192.168.65.2 in our case).
    - Combine the two above pieces of information and the ```K8S_HOST``` needs to be:
    ```shell
    export K8S_HOST=https://192.168.65.2:53682
    ```


## [Vault][Auth] Kubernetes

Set your ```VAULT_ADDR``` and ```VAULT_TOKEN``` (or whatever auth method you are leveraging) environment variables and access your Vault Service.

###### 1. Set Vault Policy
- Will re-use this policy later in the excercise
- For now, reference the ~/02-pki-build/policy/p.global.crudl.hcl or some other policy set with enough permissions to complete these steps
    ```shell
    $ vault policy write global.crudl ~/02-pki-build/policy/p.global.crudl.hcl
    ```

###### 2. Enable and configure the [***Vault K8s Auth Method***](https://www.vaultproject.io/docs/auth/kubernetes#configuration)
- Enable the **Vault K8s Auth Method** at the default path ```auth/kubernetes```
    ```shell
    $ vault auth enable kubernetes
    Success! Enabled kubernetes auth method at: kubernetes/
    ```
- Tell **Vault** how to communicate with the K8s Cluster (with data harvested from previous steps and set in environment variables ```SA_JWT_TOKEN```, ```K8S_HOST```, and ```SA_CA_CRT```).
  The ```auth/kubernetes/config``` we are using in this instance omits the line for ```      token_reviewer_jwt="$SA_JWT_TOKEN" \``` in the original instructions to accomodate **Kubernetes v1.21+** changes to ```iss``` and short-lived tokens.
  - **Vault** passes it's own ***JWT***:
    ```shell
    $ vault write auth/kubernetes/config \
      token_reviewer_jwt="$SA_JWT_TOKEN" \
      kubernetes_host="$K8S_HOST" \
      kubernetes_ca_cert="$SA_CA_CRT" \
      issuer="https://kubernetes.default.svc.cluster.local"
    Success! Data written to: auth/kubernetes/config
    ```
  - **Vault** passes Client Application's ***JWT***:
    ```shell
    $ vault write auth/kubernetes/config \
      kubernetes_host="$K8S_HOST" \
      kubernetes_ca_cert="$SA_CA_CRT" \
      issuer="https://kubernetes.default.svc.cluster.local"
    Success! Data written to: auth/kubernetes/config
    ```
    ^^ **NOTE**: ```issuer``` can be disovered via:
    ```shell
    $ echo '{"apiVersion": "authentication.k8s.io/v1", "kind": "TokenRequest"}' \
      | kubectl create -f- --raw /api/v1/namespaces/default serviceaccounts/default/token \
      | jq -r '.status.token' \
      | cut -d . -f2 \
      | base64 -D
    
    {"aud":["https://kubernetes.default.svc.cluster.local","k3s"],"exp":1654283613,"iat":1654280013,"iss":"https://kubernetes.default.svc.cluster.local","kubernetes.io":{"namespace":"default","serviceaccount":{"name":"default","uid":"dd27afbb-1c5b-4bcf-8365-17801a7f05f3"}},"nbf":1654280013,"sub":"system:serviceaccount:default:default"}
    ```
    **OR**
    ```shell
    $ kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer'

    https://kubernetes.default.svc.cluster.local
    ```
    The ```issuer``` discovery is documented here @ https://www.vaultproject.io/docs/auth/kubernetes#discovering-the-service-account-issuer
    > **CAVEAT**: https://www.vaultproject.io/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt
- Create a **Vault K8s Auth Method** ```role``` that will map the K8s **serviceaccount** to the **Vault** ```policy``` created previously
    ```shell
    $ vault write auth/kubernetes/role/example \
      bound_service_account_names=vault-auth \
      bound_service_account_namespaces=default \
      policies=global.crudl \
      disable_iss_validation=true \
      ttl=24h
    Success! Data written to: auth/kubernetes/role/example
    ```
    ```shell
    disable_iss_validation=true
    ```
###### 3. Determine Vault Address from K8s Application Perspective

>
> **NOTE**: In this case, we are running a local **Vault** Dev instance in a Docker Container. We will need to find how the K8s Pods in the K3d Cluster can access the **Vault** API as serviced by the Docker Container.
>
>The instructions in this section are specific for our **VAULT** Dev in Docker <=> **K3d** Kubernetes Cluster + Application in **default** ```namespace``` environment - use it as reference for your particular setup.
>
>Otherwise, set your application ```pod``` ```VAULT_ADDR``` environment variable to the correct URL (E.g. "http://$VAULT_ADDR:8200")
>
- Since the underlying runtime networking is on **Docker Networking**, access services running on the Docker Host Machine via the **hostname** ```host.docker.intenal``` (and/or in our **K3d** case, ```host.k3d.internal``` - should resolve to the same IP as ```host.docker.internal```)
- Find the **K3d** Nodes (running as a **Docker** Container)
    ```shell
    $ docker ps | grep -i auth-client-jwt
    0cdc109e6ebb   ghcr.io/k3d-io/k3d-tools:5.4.1         "/app/k3d-tools noop"    21 hours ago   Up 21 hours                                     k3d-auth-client-jwt-tools
    cda4169a54ba   ghcr.io/k3d-io/k3d-proxy:5.4.1         "/bin/sh -c nginx-pr…"   21 hours ago   Up 21 hours   80/tcp, 0.0.0.0:53682->6443/tcp   k3d-auth-client-jwt-serverlb
    426d2abb8b48   rancher/k3s:v1.22.7-k3s1               "/bin/k3d-entrypoint…"   21 hours ago   Up 21 hours                                     k3d-auth-client-jwt-agent-1
    8d241b540948   rancher/k3s:v1.22.7-k3s1               "/bin/k3d-entrypoint…"   21 hours ago   Up 21 hours                                     k3d-auth-client-jwt-agent-0
    3ea2aeda77c1   rancher/k3s:v1.22.7-k3s1               "/bin/k3d-entrypoint…"   21 hours ago   Up 21 hours                                     k3d-auth-client-jwt-server-0
    ```
    ^^ ```-server-``` and ```-agent--``` containers are **K3d** Master or Worker Nodes.
- **Exec** into a Master or Worker **K3d** Node, find the IP to be used to access **Vault API**, and test that API access. (In our case, the ```host.docker.internal``` IP *should* match the ```host.k3d.internal``` IP)
    ```shell
    $ docker exec -it k3d-auth-client-jwt-server-0 sh
    / # 
    / # nslookup host.docker.internal
    Server:		127.0.0.11
    Address:	127.0.0.11:53

    Non-authoritative answer:
    Name:	host.docker.internal
    Address: 192.168.65.2

    Non-authoritative answer:
    *** Can't find host.docker.internal: No answer
    / # wget -SO - http://192.168.65.2:8200/v1/sys/seal-status
    Connecting to 192.168.65.2:8200 (192.168.65.2:8200)
    HTTP/1.1 200 OK
    Cache-Control: no-store
    Content-Type: application/json
    Strict-Transport-Security: max-age=31536000; includeSubDomains
    Date: Fri, 03 Jun 2022 21:27:54 GMT
    Content-Length: 261
    Connection: close
    
    writing to stdout
    {"type":"shamir","initialized":true,"sealed":false,"t":1,"n":1,"progress":0,"nonce":"","version":"1.9.3","migration":false,"cluster_name":"vault-cluster-b9477108","cluster_id":"a94e1f3a-7e61-1016-b034-93841aa97b2d","recovery_seal":false,"storage_type":"inmem"}
    -                    100% |********************************|   261  0:00:00 ETA
    written to stdout

    ```
    ^^ Capture that ```ip``` and we will use that to embed as an environment variable into the **K8s** application ```pod```
- **OPTIONAL**: Verify **Vault K8s Auth Method** Configuration
  - Set the environment variable ```EXTERNAL_VAULT_ADDR``` with the ```ip``` harvested above
    ```shell
    $ export EXTERNAL_VAULT_ADDR=192.168.65.2
    ```
  - Define a ```pod``` with a ```container``` in YAML Manifest:
    ```shell
    $ cat > devwebapp.yaml <<EOF
    apiVersion: v1
    kind: Pod
    metadata:
    name: devwebapp
    labels:
        app: devwebapp
    spec:
    serviceAccountName: vault-auth
    containers:
        - name: devwebapp
        image: burtlo/devwebapp-ruby:k8s
        env:
            - name: VAULT_ADDR
            value: "http://$EXTERNAL_VAULT_ADDR:8200"
    EOF
    ```
    The ```pod``` is named ```devwebapp``` and runs with the ```vault-auth``` ```serviceaccount```
  - Create the ```devwebapp``` ```pod``` in the ```default``` ```namespace```
    ```shell
    $ kubectl apply --filename devwebapp.yaml --namespace default
    pod/devwebapp created
    ```
  - Display the ```pod``` in the ```default``` ```namespace```
    ```shell
    $ kubectl -n default get pod
    NAME        READY   STATUS    RESTARTS   AGE
    devwebapp   1/1     Running   0          110s
    ```
    Wait until the ```devwebapp``` pod is running and ready (```1/1```).
  - Exec into the pod container interactively and set environment variable **KUBE_TOKEN**. Stay in the container for the next step.
    ```shell
    $ export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    ```
  - Set environment variable **VAULT_ADDR**
    ```shell
    $ export VAULT_ADDR=http://$(dig +short host.k3d.internal):8200
    ```
  - ~~**JWT** from ```pod``` and ```serviceaccount``` ```secret``` **JWT** do not match. Getting ***"permission denied"*** when attempting to ```curl``` to **Vault API** from ```pod```~~ Login from Test Pod Container in ```devwebapp``` and attempt to log in to **Vault** with the ***JWT*** and retrieve the ```client_token```.  With this token, you'll be able to access **Vault** resources as defined by the Policy applied to the token (```token_policies```).
    ```shell
    $ curl --request POST \
      --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "example"}' \
      $VAULT_ADDR/v1/auth/kubernetes/login | jq
        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                      Dload  Upload   Total   Spent    Left  Speed
      100  1692  100   649  100  1043  18110  29105 --:--:-- --:--:-- --:--:-- 33645
      {
        "request_id": "1570777d-54ae-b425-56c1-e4b63a3f7f9d",
        "lease_id": "",
        "renewable": false,
        "lease_duration": 0,
        "data": null,
        "wrap_info": null,
        "warnings": null,
        "auth": {
          "client_token": "s.wQU67aXHXi5NhxrfMZ384hmJ",
          "accessor": "ujaj120gNhwSB4sYmFXiUpyi",
          "policies": [
            "default",
            "global.crudl"
          ],
          "token_policies": [
            "default",
            "global.crudl"
          ],
          "metadata": {
            "role": "example",
            "service_account_name": "vault-auth",
            "service_account_namespace": "default",
            "service_account_secret_name": "",
            "service_account_uid": "5e5b97af-1046-446e-a182-03ed7a7f8dc4"
          },
          "lease_duration": 86400,
          "renewable": true,
          "entity_id": "a8bba951-d05d-3c04-de61-5d5d67318ec8",
          "token_type": "service",
          "orphan": true
        }
      }
    ``` 
  - asdf
- asdf
  



## Reference
- https://www.vaultproject.io/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt
- git clone https://github.com/hashicorp/learn-vault-agent.git
- https://www.vaultproject.io/docs/auth/kubernetes#use-local-service-account-token-as-the-reviewer-jwt
- https://learn.hashicorp.com/tutorials/vault/agent-kubernetes#create-a-service-account
- https://www.vaultproject.io/docs/platform/k8s/injector
- https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar
- https://k3d.io/v5.2.2/faq/faq/#how-to-access-services-like-a-database-running-on-my-docker-host-machine

## Appendix

```shell
$ vault kv put secret/myapp/config \
      username='appuser' \
      password='suP3rsec(et!' \
      ttl='30s'

====== Secret Path ======
secret/data/myapp/config

======= Metadata =======
Key                Value
---                -----
created_time       2022-06-03T23:01:38.505403514Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```