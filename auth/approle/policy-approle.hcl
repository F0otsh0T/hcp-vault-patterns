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
# Set the path to "secret/data/nginx/*" if you are running `kv-v2`
path "secret/nginx/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "nginx/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "secret/data/nginx/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
