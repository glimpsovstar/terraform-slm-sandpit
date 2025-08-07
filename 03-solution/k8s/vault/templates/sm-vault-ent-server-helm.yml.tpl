global:
  enabled: true
  tlsDisable: false
injector:
  enabled: false
server:
  enabled: true
  enterpriseLicense:
    secretName: "vault-ent-license"
    secretKey: "license"
  image:
    repository: "hashicorp/vault-enterprise"
    tag: "${version}-ent"
  logLevel: "debug"
  extraEnvironmentVars:
    VAULT_CACERT: /vault/userconfig/vault-ha-tls/vault.ca
  volumes:
    - name: userconfig-vault-ha-tls
      secret:
        defaultMode: 420
        secretName: vault-tls-certificates
  volumeMounts:
    - name: userconfig-vault-ha-tls
      mountPath: /vault/userconfig/vault-ha-tls
      readOnly: true
  ha:
    enabled: true
    replicas: ${replicas}
    raft:
      enabled: true
      config: |
        cluster_name = "vault-integrated-storage"
        ui = true
        api_addr = "${api_addr}"
        listener "tcp" {
          tls_disable = 0
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          tls_cert_file = "/vault/userconfig/vault-ha-tls/vault.crt"
          tls_key_file  = "/vault/userconfig/vault-ha-tls/vault.key"
          tls_client_ca_file = "/vault/userconfig/vault-ha-tls/vault.ca"
        }
        storage "raft" {
          path = "/vault/data"
          retry_join {
            leader_api_addr = "https://vault-active:8200"
            leader_client_cert_file = "/vault/userconfig/vault-ha-tls/vault.crt"
            leader_client_key_file = "/vault/userconfig/vault-ha-tls/vault.key"
            leader_ca_cert_file = "/vault/userconfig/vault-ha-tls/vault.ca"
          }
        }

        disable_mlock = true
        service_registration "kubernetes" {}
ui:
  enabled: true
  serviceType: "LoadBalancer"