# NGINX Ingress Controller for EKS

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.0"
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = 300
  wait             = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
          }
          ports = {
            http = {
              port       = 80
              protocol   = "TCP"
              targetPort = "http"
            }
            https = {
              port       = 443
              protocol   = "TCP"
              targetPort = "https"
            }
            vault-direct = {
              port       = 8200
              protocol   = "TCP"
              targetPort = 8200
            }
          }
        }
      }
      tcp = {
        "8200" = "vault/vault-ui:8200"
      }
    })
  ]

  depends_on = [kubernetes_namespace.nginx_ingress]
}

resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "ingress-nginx"
  }
}
