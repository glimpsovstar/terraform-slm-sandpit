module "vault-machine-id-onboarding" {
  source = "github.com/phan-t/terraform-slm-sandpit/examples/patterns/nhi/02-vault-machine-id-onboarding"

  pki_mount_path          = "pki-int-machine-id"
  machine_auth_mount_path = "cert"
  machine_auth_policy     = "trusted-machine"
  pki_role                = "trusted-machine"
  common_name             = aws_instance.test-app.private_dns
  team_name               = "retailxyz"
  machine_function        = "databasexyz"
}

resource "local_sensitive_file" "vault_ca_certificate" {
  filename = "${path.module}/configs/ca-cert.pem"
  file_permission = "400"
  content = var.vault_ca_cert_pem
}

resource "local_sensitive_file" "machine_id_certificate" {
  filename = "${path.module}/configs/${aws_instance.test-app.id}.pem"
  file_permission = "400"
  content = module.vault-machine-id-onboarding.public_cert_pem
}

resource "local_sensitive_file" "machine_id_private_key" {
  filename = "${path.module}/configs/${aws_instance.test-app.id}.key"
  file_permission = "400"
  content = module.vault-machine-id-onboarding.private_key_pem
}