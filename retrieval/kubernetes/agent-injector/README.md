---
tags:
  - agent
  - hashicorp
  - hcp-vault
  - hcp-terraform
  - inject
  - injector
  - kubernetes
  - retrieval
  - sidecar
  - 
alias:
  - HashiCorp Vault Retrieval: Kubernetes Sidecar Agent Injector

---

---

# HashiCorp Vault Retrieval: Kubernetes Sidecar Agent Injector

[![High Level Flow - Vault Sidecar Agent Injector](https://www.datocms-assets.com/2885/1643214443-sidecar-workflow-v1.png?fit=max&fm=webp&q=80&w=2500)]((https://www.hashicorp.com/blog/kubernetes-vault-integration-via-sidecar-agent-injector-vs-csi-provider))

[![Kubernetes Auth Secret Zero](https://www.datocms-assets.com/2885/1643214683-vault-k8s-auth-blog.png?fit=max&fm=webp&q=80&w=2500)](https://www.hashicorp.com/blog/kubernetes-vault-integration-via-sidecar-agent-injector-vs-csi-provider)

- https://www.vaultproject.io/docs/platform/k8s/injector
- https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar
- https://www.hashicorp.com/blog/kubernetes-vault-integration-via-sidecar-agent-injector-vs-csi-provider

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

####This Repo builds on the following:

1. https://github.com/F0otsh0T/hcp-vault-docker
2. https://github.com/F0otsh0T/hcp-vault-patterns/tree/main/auth/kubernetes/kubernetes-client-jwt
3. https://github.com/F0otsh0T/hcp-vault-patterns/tree/main/auth/approle#kv2-secrets-engine
 

## Synopsis:

1. Decide on External **Vault** access options in [Access External Vault](#access-external-vault) section below ([LINK](#access-external-vault))
2. Create **Vault** Sidecar Agent Injector **Helm** `install` based on decision above ([LINK](#install-agent-injector))
3. Verify Agent Injector `serviceaccount` and `secret` ([LINK](#verify-agent-injector-serviceaccount-and-secret))
4. Deploy and Annotate Application ([LINK](#deploy-and-annotate-application))
5. Verify Secrets are Injected into `pods` ([LINK](#verify-secrets-are-injected-into-pods))

## Versions

###### Docker Version

```shell
❯ docker version
Client:
 Cloud integration: v1.0.24
 Version:           20.10.14
```

###### K3d / K3s Version

```shell
❯ k3d version
k3d version v5.4.3
k3s version v1.23.6-k3s1 (default)
```

###### Helm Version

```shell
❯ helm version
version.BuildInfo{Version:"v3.9.0", GitCommit:"7ceeda6c585217a19a1131663d8cd1f7d641b2a7", GitTreeState:"clean", GoVersion:"go1.18.2"}
```

###### Vault Version

```shell
❯ vault version
Vault v1.11.0 ('ea296ccf58507b25051bc0597379c467046eb2f1+CHANGES'), built 2022-06-17T15:48:44Z
```

## Access External Vault

#### Two Options:

- Hard code External Vault IP into each Kubernetes application (Pods
- Create Kubernetes **[Service](https://kubernetes.io/docs/concepts/services-networking/service/)** and **API [Endpoint](https://kubernetes.io/docs/concepts/services-networking/service/#services-without-selectors)** exposing External Vault API inside of Kubernetes so that Kubernetes applications (Pods) can interact with the external Vault via the internal `service` / `endpoint`
  - [Deploy service and endpoints to address an external Vault](https://learn.hashicorp.com/tutorials/vault/kubernetes-external-vault#deploy-service-and-endpoints-to-address-an-external-vault)
    ```shell
    ❯ cat > external-vault.yaml <<EOF
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: external-vault
      namespace: default
    spec:
      ports:
      - protocol: TCP
        port: 8200
    ---
    apiVersion: v1
    kind: Endpoints
    metadata:
      name: external-vault
    subsets:
      - addresses:
    #      - ip: $EXTERNAL_VAULT_ADDR
          - ip: 192.168.65.2
        ports:
          - port: 8200
    EOF
    ```

    ```shell
    ❯ kubectl apply -f external-vault.yaml
    service/external-vault created
    endpoints/external-vault created
    ```

#### Application Perspective

For applications in the **Kubernetes** cluster that wish to access the external **Vault**, they can either connect directly via a Hard-Coded **Vault** `IP` or `FQDN` or to an internal **Kubernetes** `service` @ `external-vault` or `external-vault.default.svc.cluster.local` that proxies the connection. Possible applications in question:
  1. Vault Agent Injector
  2. Your application that you wish to Inject secrets into

## Install Agent Injector

- Add the HashiCorp Helm repository.
    ```shell
    ❯ helm repo add hashicorp https://helm.releases.hashicorp.com
    "hashicorp" has been added to your repositories
    ```
- Update all the repositories to ensure helm is aware of the latest versions.
    ```shell
    ❯ helm repo update
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "hashicorp" chart repository
    Update Complete. ⎈Happy Helming!⎈
    ```
- Install the latest version of the Vault server running in external mode. This is one of the places where you can choose to hard code the External **Vault** `IP` or `FQDN` or utilize the **external-vault** **Kubernetes** `service`
  - Hard Code **Vault** `IP` or `FQDN`:
    ```shell
    ❯ helm install vault hashicorp/vault \
        --set "injector.externalVaultAddr=http://192.165.65.2:8200"
    NAME: vault
    LAST DEPLOYED: Sun Jul  3 10:54:16 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    Thank you for installing HashiCorp Vault!

    Now that you have deployed Vault, you should look over the docs on using
    Vault with Kubernetes available here:

    https://www.vaultproject.io/docs/


    Your release is named vault. To learn more about the release, try:

      $ helm status vault
      $ helm get manifest vault
    ```

  - Utilize **external-vault** **Kubernetes** `service` ([LINK](https://learn.hashicorp.com/tutorials/vault/kubernetes-external-vault#deploy-service-and-endpoints-to-address-an-external-vault))
    ```shell
    ❯ helm install vault hashicorp/vault \
        --set "injector.externalVaultAddr=http://external-vault:8200"
    NAME: vault
    LAST DEPLOYED: Sun Jul  3 10:54:16 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    Thank you for installing HashiCorp Vault!

    Now that you have deployed Vault, you should look over the docs on using
    Vault with Kubernetes available here:

    https://www.vaultproject.io/docs/


    Your release is named vault. To learn more about the release, try:

      $ helm status vault
      $ helm get manifest vault
    ```

- Verify pods are in **default** `namespace`
  ```shell
  ❯ kubectl -n default get pods
  NAME                                    READY   STATUS    RESTARTS      AGE
  vault-agent-injector-5b7d588456-g6sh8   1/1     Running   2 (65m ago)   8h
  ```

## Verify Agent Injector `serviceaccount` and `secret`

- Describe the **vault** `serviceaccount`.
  ```shell
  ❯ kubectl describe serviceaccount vault
  Name:                vault
  Namespace:           default
  Labels:              app.kubernetes.io/instance=vault
                      app.kubernetes.io/managed-by=Helm
                      app.kubernetes.io/name=vault
                      helm.sh/chart=vault-0.20.1
  Annotations:         meta.helm.sh/release-name: vault
                      meta.helm.sh/release-namespace: default
  Image pull secrets:  <none>
  Mountable secrets:   vault-token-plc5q
  Tokens:              vault-token-plc5q
  Events:              <none>
  ```
- ***Kubernetes 1.24+ only***: The name of the mountable secret is displayed in Kubernetes 1.23. In Kubernetes 1.24+, the token is not created automatically, and you must create it explicitly.
  ```shell
  ❯ cat > vault-secret.yaml <<EOF
  apiVersion: v1
  kind: Secret
  metadata:
    name: vault-token-plc5q
    annotations:
      kubernetes.io/service-account.name: vault
  type: kubernetes.io/service-account-token
  EOF
  ```
  Create the `secret`
  ```shell
  ❯ kubectl apply -f vault-secret.yaml
  secret/vault-token-plc5q created
  ```
- Create a variable named `VAULT_HELM_SECRET_NAME` that stores the secret name.
  ```shell
  ❯ VAULT_HELM_SECRET_NAME=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')
  ❯ echo $VAULT_HELM_SECRET_NAME
  vault-token-plc5q
  ```
- Describe the **vault-token** `secret`
  ```shell
  ❯ kubectl describe secret $VAULT_HELM_SECRET_NAME
  Name:         vault-token-plc5q
  Namespace:    default
  Labels:       <none>
  Annotations:  kubernetes.io/service-account.name: vault
                kubernetes.io/service-account.uid: 6256111e-ecf4-449c-b515-0545b79493e3

  Type:  kubernetes.io/service-account-token

  Data
  ====
  namespace:  7 bytes
  token:      eyJhbGciOiJSUzI1NiIsImtpZCI6Im96bjJydFJ2a0xBRlRwRDJ2TDktTjc2XzA2eV92MDdJdUl0Mmlkak03TjgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InZhdWx0LXRva2VuLXBsYzVxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNjI1NjExMWUtZWNmNC00NDljLWI1MTUtMDU0NWI3OTQ5M2UzIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6dmF1bHQifQ.V_K8SG-ohfEix1sBWp8jwMYpqDrRoXzHT3X_erslZM_qqj8D6LSX0-g-Q-90CVtTHGEtfJhrgdXY5eX2xjjd-3faWZznQVMfJ2qLiIvlucB528F4l37v03lBHz5YVOO-gSe-vav_Ic5efKXRezkbIHOrxtju98igWc8-NFQkBaYF1-qi8cHE34luZeRMavpmYeEZ9Qcsf5YqydQc4l4-Db_F6SNECA8dVWpiQ1G1hzaMnrCbkeKug__muwBWA8TeWjpO6VPtU3PSXIUYMItIAejWiV08CijzeH1NTXfMyXN6una3McF0mYjjzxNaArg1iwFCUYtolVVnGvtIEsR47w
  ca.crt:     570 bytes
  ```

## Deploy and Annotate Application

Create your application and `patch` it with **Vault** Sidecar Agent Injector `annotations`.

- Create new `deployment`
  ```shell
  ❯ cat > k8stools-with-annotations-deployment.yaml <<EOF
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: k8stools-with-annotations
    labels:
      app: k8stools-with-annotations
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: k8stools-with-annotations
    template:
      metadata:
        labels:
          app: k8stools-with-annotations
      spec:
        containers:
        - name: k8stools-with-annotations
          image: wbitt/network-multitool:alpine-extra
          env:
            - name: VAULT_ADDR
              value: "http://192.168.65.2:8200"
            - name: KUBE_TOKEN
              value: $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
          ports:
          - containerPort: 80
  EOF
  ```
  ```shell
  ❯ kubectl create -f k8stools-with-annotations-deployment.yaml
  deployment.apps/k8stools-with-annotations created
  ❯ kubectl get deployments
  NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
  vault-agent-injector        1/1     1            1           9h
  k8stools-with-annotations   1/1     1            1           7s
  ❯ kubectl get pods
  NAME                                         READY   STATUS    RESTARTS      AGE
  vault-agent-injector-5b7d588456-g6sh8        1/1     Running   2 (91m ago)   9h
  k8stools-with-annotations-7c7fb48cc9-jbq5z   1/1     Running   0             11s
  ```
- Patch `deployment` with **Vault** Agent Injector `annotations`
  ```shell
  ❯ cat > vault-secret.yaml <<EOF
  spec:
    template:
      spec:
        serviceAccountName: vault-auth
      metadata:
        annotations:
          vault.hashicorp.com/agent-inject: 'true'
          vault.hashicorp.com/role: 'example'
          vault.hashicorp.com/agent-inject-secret-kv: "nginx/secret"
          vault.hashicorp.com/agent-inject-secret-kv.json: "nginx/secret"
          vault.hashicorp.com/agent-inject-template-kv.json: |
            {{- with secret "nginx/secret" -}}
            {{ .Data.data | toJSONPretty }}
            {{- end }}
  EOF
  ```

  ```shell
  kubectl -n default patch deployment k8stools-with-annotations --patch "$(cat patch.yaml)"
  deployment.apps/k8stools-with-annotations patched
  
  ❯ kubectl get pods
  NAME                                         READY   STATUS     RESTARTS      AGE
  vault-agent-injector-5b7d588456-g6sh8        1/1     Running    2 (95m ago)   9h
  k8stools-with-annotations-7c7fb48cc9-jbq5z   1/1     Running    0             3m44s
  k8stools-with-annotations-568949ddc9-qkcxw   0/2     Init:0/1   0             6s

  ❯ kubectl get pods
  NAME                                         READY   STATUS    RESTARTS      AGE
  vault-agent-injector-5b7d588456-g6sh8        1/1     Running   2 (95m ago)   9h
  k8stools-with-annotations-568949ddc9-qkcxw   2/2     Running   0             48s
  ```

## Verify Secrets are Injected into `pods`

  ```shell
  ❯ kubectl exec deployments/k8stools-with-annotations -c k8stools-with-annotations cat /vault/secrets/kv
  data: map[foo:bar]
  metadata: map[created_time:2022-07-02T17:43:06.26018318Z custom_metadata:<nil> deletion_time: destroyed:false version:1]

  ❯ kubectl exec deployments/k8stools-with-annotations -c k8stools-with-annotations cat /vault/secrets/kv.json
  {
    "foo": "bar"
  }
  ```

## References

- https://www.vaultproject.io/docs/platform/k8s/injector
- https://www.vaultproject.io/docs/platform/k8s/injector/annotations
- https://learn.hashicorp.com/tutorials/vault/agent-kubernetes
- https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar
- https://learn.hashicorp.com/tutorials/vault/kubernetes-external-vault
- https://www.hashicorp.com/blog/kubernetes-vault-integration-via-sidecar-agent-injector-vs-csi-provider


