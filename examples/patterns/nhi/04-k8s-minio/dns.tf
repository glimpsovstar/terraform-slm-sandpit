data "aws_route53_zone" "hashidemos" {
  name         = "${var.route53_sandbox_prefix}.sbx.hashidemos.io"
  private_zone = false
}

resource "aws_route53_record" "minio-console" {
  zone_id = data.aws_route53_zone.hashidemos.zone_id
  name    = "minio-console"
  type    = "CNAME"
  ttl     = 300
  records = [
    data.kubernetes_service.minio-console.status.0.load_balancer.0.ingress.0.hostname
]
}