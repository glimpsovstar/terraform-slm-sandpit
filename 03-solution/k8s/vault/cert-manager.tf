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
}

# cert-manager Helm deployment for Let's Encrypt SSL certificates
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.16.2"
  namespace        = "cert-manager"
  create_namespace = true
  timeout          = 300
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }

  depends_on = [helm_release.nginx_ingress]
}

# Let's Encrypt ClusterIssuer for staging (for testing)
resource "local_file" "letsencrypt_staging_issuer" {
  content = <<-EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: david.joo@hashicorp.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

  filename = "${path.module}/letsencrypt-staging-issuer.yaml"
  depends_on = [helm_release.cert_manager]
}

resource "null_resource" "apply_letsencrypt_staging" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.letsencrypt_staging_issuer.filename}"
  }

  depends_on = [
    helm_release.cert_manager,
    local_file.letsencrypt_staging_issuer
  ]
}

# Let's Encrypt ClusterIssuer for production
resource "local_file" "letsencrypt_prod_issuer" {
  content = <<-EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: david.joo@hashicorp.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

  filename = "${path.module}/letsencrypt-prod-issuer.yaml"
  depends_on = [helm_release.cert_manager]
}

resource "null_resource" "apply_letsencrypt_prod" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.letsencrypt_prod_issuer.filename}"
  }

  depends_on = [
    helm_release.cert_manager,
    local_file.letsencrypt_prod_issuer
  ]
}
