# pid_file = "./pidfile"

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
      ca_cert = "/opt/vault/tls/ca-cert.pem"
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

api_proxy {
  use_auto_auth_token = "force"
  enforce_consistency = "always"
}

# cache {
# }

listener "tcp" {
   address     = "127.0.0.1:8200"
   tls_cert_file = "/opt/vault/tls/client_tls.crt"
   tls_key_file  = "/opt/vault/tls/client_tls.key"
}

template_config {
}

template {
  source      = "/var/tmp/vault-configs/secrets.json.tmp"
  destination = "/var/tmp/secrets.json"
}