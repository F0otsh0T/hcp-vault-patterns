#outputs.tf

## NAMESPACE: Parent

output "vault_namespace_parent" {
  description = "Parent Namespace"
  value       = vault_namespace.parent
}

output "vault_namespace_parent_id" {
  description = "Parent Namespace ID"
  value       = vault_namespace.parent.namespace_id
}

output "vault_namespace_parent_namespace_id" {
  description = "Parent Namespace Namespace ID"
  value       = vault_namespace.parent.namespace_id
}

output "vault_namespace_parent_path" {
  description = "Parent Namespace Path"
  value       = vault_namespace.parent.path
}
output "vault_namespace_parent_path_fq" {
  description = "Parent Namespace Path FQ"
  value       = vault_namespace.parent.path_fq
}

## NAMESPACE: Children

output "vault_namespace_children" {
  description = "Children Namespaces"
  #    value = values(vault_namespace.children)[*]
  value = values(vault_namespace.children)
}

output "vault_namespace_children_id" {
  description = "Children Namespace IDs"
  value       = values(vault_namespace.children)[*].id
}

output "vault_namespace_children_namespace_id" {
  description = "Children Namespace Names"
  value       = values(vault_namespace.children)[*].namespace_id
}

output "vault_namespace_children_path" {
  description = "Children Namespace Path"
  value       = values(vault_namespace.children)[*].path
}

output "vault_namespace_children_path_fq" {
  description = "Children Namespace Path FQ"
  value       = values(vault_namespace.children)[*].path_fq
}

output "vault_policy_edu_admin" {
  description = "Vault Policy edu-admin"
  value       = vault_policy.edu-admin
}

output "vault_policy-training_admin" {
  description = "Vault Policy training-admin"
  value       = vault_policy.training-admin
}

output "vault_auth_backend_userpass" {
  description = "Vault Auth Backend UserPass"
  value       = vault_auth_backend.userpass
}

output "vault_user_bob" {
  description = "Vault UserPass User `bob`"
  value       = vault_generic_endpoint.bob
  sensitive   = true
}

output "vault_entity_bob_smith" {
  description = "Vault Entity `Bob Smith`"
  value       = vault_identity_entity.bob_smith
}

output "vault_entity_alias_bob_smith_to_bob" {
  description = "Vault Entity Alias `Bob Smith` to `bob`"
  value       = vault_identity_entity_alias.bob_smith_to_bob
}

output "vault_identity_group_training_admin" {
    description = "Vault Identity Group `Training Admin`"
    value = vault_identity_group.training_admin
}


