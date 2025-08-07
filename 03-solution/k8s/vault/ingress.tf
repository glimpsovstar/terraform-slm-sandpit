# Vault Ingress with Let's Encrypt SSL

# Vault Ingress with conditional Let's Encrypt SSL

resource "kubernetes_ingress_v1" "vault" {
  metadata {
    name      = "vault-ingress"
    namespace = "vault"
    annotations = merge(
      {
        "kubernetes.io/ingress.class"                         = "nginx"
        "nginx.ingress.kubernetes.io/backend-protocol"        = "HTTPS"
        "nginx.ingress.kubernetes.io/proxy-ssl-verify"        = "off"
        "nginx.ingress.kubernetes.io/proxy-ssl-server-name"   = "on"
      },
      var.use_route53_dns ? {
        "cert-manager.io/cluster-issuer" = var.use_letsencrypt_prod ? "letsencrypt-prod" : "letsencrypt-staging"
      } : {}
    )
  }

  spec {
    # Only add TLS configuration when using Route53 DNS (for Let's Encrypt)
    dynamic "tls" {
      for_each = var.use_route53_dns ? [1] : []
      content {
        hosts       = [local.vault_hostname]
        secret_name = "vault-tls-cert"
      }
    }

    rule {
      host = local.vault_hostname
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
