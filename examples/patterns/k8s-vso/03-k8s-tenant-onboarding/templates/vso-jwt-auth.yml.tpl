apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  namespace: tenant3
  name: vso-jwt-auth
spec:
  namespace: tenanta
  method: jwt
  mount: jwt
  jwt:
    role: tenanta
    serviceAccount: vso-jwt-auth