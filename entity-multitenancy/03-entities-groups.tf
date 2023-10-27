# 03-entities_groups.tf
# https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces#set-up-entities-and-groups


## Enable the `userpass` auth method in the `education` (Parent) Namespace
resource "vault_auth_backend" "userpass" {
  type      = "userpass"
  namespace = vault_namespace.parent.path_fq
}

## Create a user `bob` under the `education` (Parent) Namespace 
resource "vault_generic_endpoint" "bob" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/bob"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "password": "training"
}
EOT
}

## Create an entity for `Bob Smith` in NameSpace `education` with `edu-admin` policy attached
resource "vault_identity_entity" "bob_smith" {
  name      = "Bob Smith"
  namespace = vault_namespace.parent.path_fq
  #  namespace = "education"
  policies = ["edu-admin"]
  metadata = {
    foo = "bar"
  }
}

## Create an entity alias for `Bob Smith` to attach `bob`
resource "vault_identity_entity_alias" "bob_smith_to_bob" {
  name      = "bob"
  namespace = vault_namespace.parent.path_fq
  #  namespace = "education"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.bob_smith.id
}

## Create a group, "Training Admin" in `education/training` namespace with `Bob Smith` entity as its member.
resource "vault_identity_group" "training_admin" {
  name = "Training Admin"
  type = "internal"
  policies = [
    "training-admin"
  ]
  member_entity_ids = [
    vault_identity_entity.bob_smith.id
  ]
}





