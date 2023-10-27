# 02-policies.tf
# https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces#write-policies

resource "vault_policy" "edu-admin" {
  name      = "edu-admin"
  namespace = vault_namespace.parent.path_fq
  depends_on = [
   vault_namespace.parent
  ]
  policy = <<EOT
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Create and manage entities and groups
path "identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets at 'edu-secret'
path "edu-secret/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

EOT
}

resource "vault_policy" "training-admin" {
  name = "training-admin"
  #  namespace = values(vault_namespace.children)[1].path_fq
  namespace = "education/training"
  depends_on = [
   vault_namespace.children
  ]
  policy = <<EOT
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
  capabilities = ["list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Manage secrets at 'team-secret'
path "team-secret/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

EOT
}







