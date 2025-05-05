path "pki-int-machine-id/issue/*" {
capabilities = ["create", "update"]
}

path "pki-int-machine-id/certs" {
capabilities = ["list"]
}

path "pki-int-machine-id/revoke" {
capabilities = ["create", "update"]
}

path "pki-int-machine-id/tidy" {
capabilities = ["create", "update"]
}

path "pki-root/cert/ca" {
capabilities = ["read"]
}

path "auth/token/renew" {
capabilities = ["update"]
}

path "auth/token/renew-self" {
capabilities = ["update"]
}

# Roles to create, update secrets
path "/sys/mounts" {
capabilities = ["read", "update", "list"]
}

path "/sys/mounts/*" {
capabilities = ["update", "create"]
}

path "sys/policies/acl" {
capabilities = ["read"]
}

path "secret/*" {
capabilities = ["read", "create", "update", "delete"]
}