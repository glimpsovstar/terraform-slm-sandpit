apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  namespace: ${tenant_name}
  name: vso-auth
spec:
  namespace: ${tenant_name}
  method: jwt
  mount: jwt
  jwt:
    role: ${tenant_name}
    serviceAccount: vso-auth