mode: standalone
rootUser: "root"
rootPassword: "${root_password}"
replicas: 1
trustedCertsSecret: "minio-trusted-certs"
persistence:
  enabled: true
  size: 10Gi
service:
  type: LoadBalancer
consoleService:
  type: LoadBalancer
resources:
  requests:
    memory: 512Mi
oidc:
  enabled: true
  configUrl: "${oidc_provider_address}"
  clientId: "${oidc_client_id}"
  clientSecret: "${oidc_client_secret}"
  claimName: "minio"
  scopes: "openid,profile,email,policies"
  redirectUri: "${oidc_redirect_uri}"
  claimPrefix: ""
  displayName: "Vault"