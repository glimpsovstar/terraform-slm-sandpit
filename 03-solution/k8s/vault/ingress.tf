# Vault Ingress with Let's Encrypt SSL

resource "kubernetes_ingress_v1" "vault" {
  metadata {
    name      = "vault-ingress"
    namespace = "vault"
    annotations = {
      "kubernetes.io/ingress.class"                         = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol"        = "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-ssl-verify"        = "off"
      "nginx.ingress.kubernetes.io/proxy-ssl-server-name"   = "on"
      "cert-manager.io/cluster-issuer"                      = var.use_letsencrypt_prod ? "letsencrypt-prod" : "letsencrypt-staging"
    }
  }

  spec {
    tls {
      hosts       = ["vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io"]
      secret_name = "vault-tls-cert"
    }

    rule {
      host = "vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "vault-ui"
              port {
                number = 8200
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.vault_ui_nodeport
  ]
}

# Create a NodePort service for Vault UI (for ingress to connect to)
resource "kubernetes_service" "vault_ui_nodeport" {
  metadata {
    name      = "vault-ui-nodeport"
    namespace = "vault"
  }

  spec {
    type = "NodePort"
    port {
      port        = 8200
      target_port = 8200
      protocol    = "TCP"
    }
    
    selector = {
      "app.kubernetes.io/name"      = "vault"
      "app.kubernetes.io/instance"  = "vault"
      "component"                   = "server"
    }
  }
}
