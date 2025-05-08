pid_file = "./pidfile"

log_file = "/var/log/vault-agent.log"

vault {
  address = "${vault_address}"
  client_cert = "/opt/vault/tls/client_tls.crt"
  client_key = "/opt/vault/tls/client_tls.key"
  tls_skip_verify = true
  retry {
    num_retries = 5
  }
}

auto_auth {
  method "cert" {
    config {
      name = "${role}"
      client_cert = "/opt/vault/tls/client_tls.crt"
      client_key = "/opt/vault/tls/client_tls.key"
    }
  }
  
  sink "file" {
    config {
      path = "/opt/vault/tls/token"
    }
  }
}

# cache {
# }

listener "tcp" {
   address     = "127.0.0.1:8100"
   tls_disable = true
}