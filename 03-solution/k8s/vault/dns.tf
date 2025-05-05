data "aws_route53_zone" "hashidemos" {
  name         = "${var.route53_sandbox_prefix}.sbx.hashidemos.io"
  private_zone = false
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.hashidemos.zone_id
  name    = "vault"
  type    = "CNAME"
  ttl     = 300
  records = [
    data.kubernetes_service.vault-ui.status.0.load_balancer.0.ingress.0.hostname
]
}