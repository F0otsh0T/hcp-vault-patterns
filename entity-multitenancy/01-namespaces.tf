# 01-namespaces.tf
# https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces#create-namespaces

resource "vault_namespace" "parent" {
  path = var.vault_namespace_parent
}

resource "vault_namespace" "children" {
  for_each  = var.vault_namespace_children
  namespace = vault_namespace.parent.path
  path      = each.value.path
}
