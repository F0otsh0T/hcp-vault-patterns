# VAULT / AUTH - OIDC Azure Active Directory

> "Auth methods are the components in Vault that perform authentication and are responsible for assigning identity and a set of policies to a user. In all cases, Vault will enforce authentication as part of the request processing. In most cases, Vault will delegate the authentication administration and decision to the relevant configured external auth method (e.g., Amazon Web Services, GitHub, Google Cloud Platform, Kubernetes, Microsoft Azure, Okta ...)."
>
> https://developer.hashicorp.com/vault/docs/auth

## BACKGROUND
This pattern utilizes Azure AD via OIDC and Vault Auth to enable AuthN for guest access into an Azure Tenant Application.  In this case, the Application will be Vault itself.

This pattern is built largely from the HashiCorp Learn Guide tutorials found in the links in the [REFERENCES](#references) section below.

## PREREQUISITES
- Azure Subscription
- AZ CLI
- Vault
- JQ

## STEPS

###### [Register Vault as a web app](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure#register-vault-as-a-web-app)

- **ENV** `AD_AZURE_DISPLAY_NAME`: Set AZ AD APP Registration Name
  ```shell
  export AD_AZURE_DISPLAY_NAME=myapp-vault-$(xxd -l 4 -p < /dev/random)
  ```
- **ENV** `AD_VAULT_APP_ID`: Register and create AZ AD APP with two redirect URIs (also called `reply-urls`) and harvest `appId`
  ```shell
  export AD_VAULT_APP_ID=$(az ad app create \
    --display-name ${AD_AZURE_DISPLAY_NAME} \
    --web-redirect-uris "http://localhost:8250/oidc/callback" \
    "${VAULT_ADDR}/ui/vault/auth/oidc/oidc/callback" | \
    jq > appreg.json | \
    jq -r '.appId')
  ```
- **ENV** `AD_MICROSOFT_GRAPH_API_ID`: Retrieve the application ID of the [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/use-the-api), which allows you to access Azure service resources. This ID will be used to attach API permissions to the app registration.
  ```shell
  export AD_MICROSOFT_GRAPH_API_ID=$(az ad sp list \
    --filter "displayName eq 'Microsoft Graph'" \
    --query '[].appId' -o tsv)
  ```
- **ENV**: `AD_PERMISSION_GROUP_MEMBER_READ_ALL_ID`: Using the Microsoft Graph API ID, retrieve the ID of the permission for `GroupMember.Read.All`.
  ```shell
  export AD_PERMISSION_GROUP_MEMBER_READ_ALL_ID=$(az ad sp show \
    --id ${AD_MICROSOFT_GRAPH_API_ID} \
    --query "oauth2PermissionScopes[?value=='GroupMember.Read.All'].id" -o tsv)
  ```
- Add the GroupMember.Read.All [permission](https://docs.microsoft.com/en-us/graph/permissions-reference#delegated-permissions-25) to the application. This allows the application to read an Active Directory group and its users.
  ```shell
  az ad app permission add \
    --id ${AD_VAULT_APP_ID} \
    --api ${AD_MICROSOFT_GRAPH_API_ID} \
    --api-permissions ${AD_PERMISSION_GROUP_MEMBER_READ_ALL_ID}=Scope
  ```
  **NOTE**: If you would want to use UPN instead of email, you may need to add additional permissions such as User.Read and profile.
- Create a `service principal` to attach to the application. The service principal allows you to grant administrative consent from the Azure CLI.
  ```shell
  az ad sp create --id ${AD_VAULT_APP_ID} | jq > appreg-sp.json
  cat appreg-sp.json | jq
  ```
- Grant administrative consent for the application to access the Microsoft Graph API.
  ```shell
  az ad app permission grant --id ${AD_VAULT_APP_ID} \
    --api ${AD_MICROSOFT_GRAPH_API_ID} \
    --scope ${AD_PERMISSION_GROUP_MEMBER_READ_ALL_ID} | \
    jq > appreg-grant.json
  ```
- **ENV** `AD_TENANT_ID`: Retrieve the Azure tenant ID for the application and set it to the `AD_TENANT_ID` environment variable.
  ```shell
  export AD_TENANT_ID=$(az ad sp show --id ${AD_VAULT_APP_ID} \
    --query 'appOwnerOrganizationId' -o tsv)
  ```
- **ENV** `AD_CLIENT_SECRET`: Set/Reset the client secret for the application and set the password to the `AD_CLIENT_SECRET` environment variable. You will need the secret to configure the OIDC auth method in Vault.
  ```shell
  export AD_CLIENT_SECRET=$(az ad app credential reset \
      --id ${AD_VAULT_APP_ID} | \
      jq > appreg-pass.json | \
      jq -r '.password')
  ```
---
###### [Update application group claims and ID tokens](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure#update-application-group-claims-and-id-tokens)
In order to use AD groups to authenticate to Vault, you need to update the Vault application in Azure with a claim for group membership information.
- Create a file named `manifest.json` with the specification for an ID token for an AD group.
  ```shell
  cat > manifest.json << EOF
  {
  "idToken": [
      {
          "name": "groups",
          "additionalProperties": []
      },
      {
          "name": "email",
          "additionalProperties": []
      }
    ]
  }
  EOF
  ```
- Update the application with the claims manifest in `manifest.json` and set `groupMembershipClaims` to `SecurityGroup`. You can expand the [group type](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-optional-claims) to additional groups.
  ```shell
  az ad app update --id ${AD_VAULT_APP_ID} \
      --set groupMembershipClaims=SecurityGroup \
      --optional-claims @manifest.json
  ```
---
###### [Create Vault policies for an example group](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure#create-vault-policies-for-an-example-group)
Every client token has policies attached to it to control its secret access. You must create the policies before defining them in the OIDC configuration.  There are two places to apply `policy` in OIDC Auth: OIDC Roles and External Groups.  Use the `default` `policy` in the OIDC Role as a catch all and apply specific `policy` at the External Group level for more granularity of control.

- Create an example Vault policies that allows an application development team to access and modify secrets.
  - Policy @p.oidc.admin.hcl
    ```shell
    cat > p.oidc.admin.hcl << EOF
    # Mount the OIDC auth method
    path "sys/auth/oidc" {
      capabilities = [ "create", "read", "update", "delete", "sudo" ]
    }

    # Configure the OIDC auth method
    path "auth/oidc/*" {
      capabilities = [ "create", "read", "update", "delete", "list" ]
    }

    # Write ACL policies
    path "sys/policies/acl/*" {
      capabilities = [ "create", "read", "update", "delete", "list" ]
    }

    # List available secrets engines to retrieve accessor ID
    path "sys/mounts" {
      capabilities = [ "read" ]
    }

    # Manage secrets engines
    path "sys/mounts/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    # List, create, update, and delete key/value secrets
    path "secret/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

    EOF
    ```
  - Policy @p.oidc.read.hcl
    ```shell
    # Mount the OIDC auth method
    path "sys/auth/oidc" {
      capabilities = [ "read", "list" ]
    }

    # Configure the OIDC auth method
    path "auth/oidc/*" {
      capabilities = [ "read", "list" ]
    }

    # Write ACL policies
    path "sys/policies/acl/*" {
      capabilities = [ "read", "list" ]
    }

    # List available secrets engines to retrieve accessor ID
    path "sys/mounts" {
      capabilities = [ "read" ]
    }

    # Manage secrets engines
    path "sys/mounts/*"
    {
      capabilities = [ "read", "list" ]
    }

    # List, create, update, and delete key/value secrets
    path "secret/*"
    {
      capabilities = [ "read", "list" ]
    }
    ```
- Write polices to Vault
  ```shell
  vault policy write p.oidc.read p.oidc.read.hcl
  vault policy write p.oidc.admin p.oidc.admin.hcl

  Success! Uploaded policy: p.oidc.read
  Success! Uploaded policy: p.oidc.admin
  ```
- Enable KV Secrets Engine
  ```shell
  vault secrets enable -version=2 -path=oidc kv

  Success! Enabled the kv secrets engine at: oidc/
  ```
- Create a sample entry in the KV secrets engine.
  ```shell
  vault kv put oidc/azure hello=world
  = Secret Path =
  oidc/data/azure

  ======= Metadata =======
  Key                Value
  ---                -----
  created_time       2022-12-02T20:28:38.325541211Z
  custom_metadata    <nil>
  deletion_time      n/a
  destroyed          false
  version            1
  ```

---

###### [Configure Vault with the OIDC auth method](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure#configure-vault-with-the-oidc-auth-method)

OIDC must be enabled and configured before it can be used. In this section, you will configure OIDC for a role named `app-dev`, which application development teams can use to log in and access secrets.

- Set the `VAULT_LOGIN_ROLE` environment variable to `app-dev`. In your own configuration, you can change this role name.
  ```shell
  export VAULT_LOGIN_ROLE=app-dev
  ```
- Enable the OIDC auth method on the Vault server.
  ```shell
  vault auth enable oidc

  Success! Enabled oidc auth method at: oidc/
  ```
- Configure the OIDC auth method with the application ID, client secret, and tenant ID of your Vault application in Azure AD.
  ```shell
  vault write auth/oidc/config \
      oidc_client_id="${AD_VAULT_APP_ID}" \
      oidc_client_secret="${AD_CLIENT_SECRET}" \
      default_role="${VAULT_LOGIN_ROLE}" \
      oidc_discovery_url="https://login.microsoftonline.com/${AD_TENANT_ID}/v2.0"
  
  Success! Data written to: auth/oidc/config
  ```
  **NOTE**: Further information for configuring the OIDC auth method for use with Azure AD is available in the [Azure Active Directory (AAD)](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread) section of the OIDC Provider Configuration documentation.
- Add [OIDC Role(s)](https://developer.hashicorp.com/vault/api-docs/auth/jwt#create-role) to Vault that uses the Vault policies created in previous steps. It authenticates to Azure by a user's email. In addition, it passes the `group_claim` of `groups` you previously configured as part of the claims manifest. The `oidc_scopes` should be set to the `https://graph.microsoft.com/.default`, which is the Microsoft Graph API.
  - Role for Azure AD Group AuthN
    ```shell
    vault write auth/oidc/role/oidc_role_aad_group \
      user_claim="email" \
      allowed_redirect_uris="http://localhost:8250/oidc/callback" \
      allowed_redirect_uris="${VAULT_ADDR}/ui/vault/auth/oidc/oidc/callback" \
      groups_claim="groups" \
      oidc_scopes="https://graph.microsoft.com/.default" \
      token_no_default_policy="true"
    
    Success! Data written to: auth/oidc/role/oidc_role_aad_group
    ```
  - **B2B**: Role for Azure AD App Registration / Enterprise Application App Role with attribute `groups_claim="role"`
    ```shell
    vault write auth/oidc/role/oidc_role_appreg_approle \
      user_claim="email" \
      allowed_redirect_uris="http://localhost:8250/oidc/callback" \
      allowed_redirect_uris="${VAULT_ADDR}/ui/vault/auth/oidc/oidc/callback" \
      groups_claim="roles" \
      oidc_scopes="https://graph.microsoft.com/.default" \
      token_no_default_policy="true"
    
    Success! Data written to: auth/oidc/role/oidc_role_appreg_approle
    ```
  **NOTE**:
   - If you want to use UPN instead of user email, change the `user_claim` field to `upn`.
   - If you choose to apply a policy to this role, any entity that authenticates with this role will have authorization based on that policy. In this case, we elected to have no token policy (`token_no_default_policy="true"`)

---

###### [Set up a Vault external group for the AD group](https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure#set-up-a-vault-external-group-for-the-ad-group)

Create an Active Directory group with a set of application development team users. Connect this Azure AD group to a Vault policy, which will allow any users in the Azure AD group to log into Vault by email and access secrets.

- Create an Azure AD group.
  ```shell
  az ad group create \
    --display-name hashicorp-$AD_AZURE_DISPLAY_NAME \
    --mail-nickname hashicorp-$AD_AZURE_DISPLAY_NAME | \
    jq > appreg-group-aadgroup.json
  export AD_GROUP_ID=$(cat appreg-group-aadgroup.json | jq -r '.id')
  ```
- Add the user authenticated with the Azure CLI to the new AD group.
  ```shell
  az ad group member add --group hashicorp-$AD_AZURE_DISPLAY_NAME \
    --member-id $(az ad signed-in-user show | jq -r .id)
  ```
- **ENV** `VAULT_EXTERNAL_GROUP_ID`: Create a Vault [external group](https://developer.hashicorp.com/vault/tutorials/auth-methods/identity#create-an-external-group). This is a Vault placeholder / bucket to represent the AZ AD Group.
  ```shell
  export VAULT_EXTERNAL_GROUP_ID=$(vault write -format=json \
    identity/group \
    name="${VAULT_LOGIN_ROLE}" \
    policies="p.oidc.read" \
    type="external" \
    metadata=displayName="hashicorp-gcsajohnny-vault-7bcceb21" | \
    jq > appreg-vault-externalgroup.json | \
    jq -r ".data.id")
  ```

---

###### [Connect AD group with Vault external group](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread#connect-ad-group-with-vault-external-group)

- Harvest two pieces of information
  - **ENV** `VAULT_OIDC_ACCESSOR_ID`: Vault [OIDC Accessor ID](https://developer.hashicorp.com/vault/api-docs/system/auth#list-auth-methods)
    ```shell
    export VAULT_OIDC_ACCESSOR_ID=$(vault auth list -format=json | jq -r '."oidc/".accessor')

    auth_oidc_Loremips
    ```
  - **ENV** `AD_GROUP_ID`: Azure AD Group `Object Id` (via Portal GUI) or the `.id` value from the JSON ouput from the "[Create an Azure AD group](#set-up-a-vault-external-group-for-the-ad-group)" section above (**ENV** `AD_GROUP_ID` )
- In Vault, create a [group-alias](https://developer.hashicorp.com/vault/api-docs/secret/identity/group-alias) for the external group and set the objectId as the group alias name. This is the glue that links the AZ AD Group to the Vault Group Alias. The AD_GROUP_ID (.id of the AAD Group) is used for AAD Groups.
  ```shell
  vault write -format=json identity/group-alias \
    name="${AD_GROUP_ID}" \
    mount_accessor="${VAULT_OIDC_ACCESSOR_ID}" \
    canonical_id="${VAULT_EXTERNAL_GROUP_ID}" | \
    jq > appreg-vault-groupalias-aadgroup.json | \
    jq -r '.data'
  ```

---

###### Log into Vault via OIDC Auth

- Unset the VAULT_TOKEN environment variable. When you authenticate with Azure you will receive a new token based on the OIDC configuration.
  ```shell
  unset VAULT_TOKEN
  ```


- Try to log into the server with the OIDC auth method as a member of the AD group you configured with Vault. If it is successful, the command launches a browser to Azure for you to log in and return a Vault token.
```shell
vault login -method=oidc role="oidc_role_aad_group"
Complete the login via your OIDC provider. Launching browser to:

    https://login.microsoftonline.com/...


Waiting for OIDC authentication to complete...
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.Loremipsumdolorsitametconsecteturadipiscingelitseddoeiusmodtemporincididuntutlaboreetdoloremagnaaliqu
token_accessor       Loremipsumdolorsitametco
token_duration       768h
token_renewable      true
token_policies       ["default" "p.oidc.read"]
identity_policies    []
policies             ["default" "p.oidc.read"]
token_meta_role      oidc_role_aad_group

```

---

## REFERENCES

- https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure
- https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread
- https://developer.hashicorp.com/vault/tutorials/auth-methods/identity#create-an-external-group
- https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc
- https://learn.microsoft.com/en-us/cli/azure/use-cli-effectively?tabs=bash%2Cbash2#rest-api-commands-az-rest
- https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-rest

## APPENDIX

