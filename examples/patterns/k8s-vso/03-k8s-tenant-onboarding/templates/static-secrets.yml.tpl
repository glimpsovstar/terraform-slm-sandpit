apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: vault-kv
  namespace: ${tenant_name}
spec:
  type: kv-v2
  mount: secrets
  path: ${vault_path}
  namespace: ${tenant_name}
  destination:
    name: ${vault_path}
    create: true
  refreshAfter: 30s
