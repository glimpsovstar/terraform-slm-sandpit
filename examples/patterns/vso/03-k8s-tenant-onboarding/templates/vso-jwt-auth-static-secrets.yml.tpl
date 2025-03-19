apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: vault-kv
  namespace: tenant3
spec:
  type: kv-v2
  mount: secrets
  path: sample1
  namespace: tenanta
  destination:
    name: sample1
    create: true
  refreshAfter: 30s
  vaultAuthRef: vso-jwt-auth
