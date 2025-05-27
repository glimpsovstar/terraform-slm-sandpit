locals {
  key_pair_private_key = file("../../../${var.deployment_id}.pem")
}

resource "local_file" "agent-config" {
  content = templatefile("${path.module}/templates/vault.hcl.tpl", {
    vault_address = var.vault_address
    role = aws_instance.test-app.id
    })
  filename = "${path.module}/configs/agent-config.hcl.tmp"
}

resource "local_file" "secres-template" {
  content = templatefile("${path.module}/templates/secrets.json.tpl", {
    token_role = aws_instance.test-app.id
    })
  filename = "${path.module}/configs/secrets.json.tmp"
}

data "aws_ami" "ubuntu2404_vault" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["vault-${var.vault_version}-ent-ubuntu-*"]
  }

  filter {
    name   = "tag:application"
    values = ["vault-enterprise"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "archive_file" "config-bundle" {
  type        = "zip"
  source_dir = "${path.module}/configs"
  output_path = "${path.module}/config-bundle.zip.tmp"

  depends_on = [
    local_sensitive_file.machine_id_certificate,
    local_sensitive_file.machine_id_private_key,
    local_file.agent-config
  ]
}

resource "aws_instance" "test-app" {
  ami             = data.aws_ami.ubuntu2404_vault.id
  instance_type   = "t2.small"
  key_name        = var.deployment_id
  subnet_id       = element(data.aws_subnets.private.ids, 1)
  security_groups = [data.aws_security_group.ssh.id, data.aws_security_group.vault.id]
  
  tags = {
    Name  = "${var.deployment_id}-test-app"
  }
}

resource "terraform_data" "test-app" {
  triggers_replace = aws_instance.test-app.id

  connection {
    host          = aws_instance.test-app.private_dns
    user          = "ubuntu"
    agent         = false
    private_key   = local.key_pair_private_key
    bastion_host  = var.bastion_public_fqdn
  }

  provisioner "file" {
    source      = data.archive_file.config-bundle.output_path
    destination = "/var/tmp/vault-config-bundle.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo unzip -d /var/tmp/vault-configs /var/tmp/vault-config-bundle.zip",
      "sudo cp -f /var/tmp/vault-configs/ca-cert.pem /opt/vault/tls/ca-cert.pem",
      "sudo cp -f /var/tmp/vault-configs/i-*.pem /opt/vault/tls/client_tls.crt",
      "sudo cp -f /var/tmp/vault-configs/i-*.key /opt/vault/tls/client_tls.key",
      "sudo chown vault:vault /opt/vault/tls/ca-cert.pem",
      "sudo chown vault:vault /opt/vault/tls/client_tls.crt",
      "sudo chown vault:vault /opt/vault/tls/client_tls.key",
      "sudo cp -f /var/tmp/vault-configs/agent-config.hcl.tmp /etc/vault.d/agent-config.hcl",
    ]
  }
}