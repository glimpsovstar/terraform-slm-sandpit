data "aws_route53_zone" "hashidemos" {
  name         = "${var.route53_sandbox_prefix}.sbx.hashidemos.io"
  private_zone = false
}

# Get the NGINX Ingress Controller LoadBalancer hostname
data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  
  depends_on = [kubernetes_ingress_v1.vault]
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.hashidemos.zone_id
  name    = "vault"
  type    = "CNAME"
  ttl     = 300
  records = [
    data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
  ]
}