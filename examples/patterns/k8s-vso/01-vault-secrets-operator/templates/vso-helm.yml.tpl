defaultVaultConnection:
  enabled: true
  address: "${vault_address}"
  skipTLSVerify: true
defaultAuthMethod:
  enabled: true
  namespace: "${vault_namespace}"
  allowedNamespaces: ["*"]
  method: "kubernetes"
  mount: "kubernetes"
  kubernetes:
    role: "${vault_role}"
    serviceAccount: "vso-auth"