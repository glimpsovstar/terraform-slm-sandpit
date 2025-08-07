# Local variables for hostname calculation
locals {
  # Build hostnames conditionally based on DNS preference
  route53_hostname = "vault.${var.route53_sandbox_prefix}.sbx.hashidemos.io"
  # For AWS LB mode, hostname will be determined after deployment
  vault_hostname = var.use_route53_dns ? local.route53_hostname : "vault-${var.deployment_id}"
}

data "aws_route53_zone" "hashidemos" {
  count        = var.use_route53_dns ? 1 : 0
  name         = "${var.route53_sandbox_prefix}.sbx.hashidemos.io"
  private_zone = false
}

# Get the NGINX Ingress Controller LoadBalancer hostname (only when using Route53)
data "kubernetes_service" "nginx_ingress" {
  count = var.use_route53_dns ? 1 : 0
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  
  depends_on = [kubernetes_ingress_v1.vault]
}

resource "aws_route53_record" "vault" {
  count   = var.use_route53_dns ? 1 : 0
  zone_id = data.aws_route53_zone.hashidemos[0].zone_id
  name    = "vault"
  type    = "CNAME"
  ttl     = 300
  records = [
    data.kubernetes_service.nginx_ingress[0].status.0.load_balancer.0.ingress.0.hostname
  ]
}