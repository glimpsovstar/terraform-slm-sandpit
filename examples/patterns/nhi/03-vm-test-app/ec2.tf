locals {
  key_pair_private_key = file("../../../${var.deployment_id}.pem")
}

# resource "local_file" "xks-proxy-config" {
#   content = templatefile("${path.root}/templates/settings_vault.toml.tpl", {
#     aws_region = var.region
#     path_libvault_pkcs11 = "/usr/local/lib/xks-vault-configs/libvault-pkcs11.so"
#     })
#   filename = "${path.root}/configs/settings_vault.toml"
# }

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

resource "aws_instance" "test-app" {
  ami             = data.aws_ami.ubuntu2404_vault.id
  instance_type   = "t2.small"
  key_name        = var.deployment_id
  subnet_id       = element(data.aws_subnets.private.ids, 1)
  # security_groups = [data.aws_security_group.ssh.id, data.aws_security_group.vault.id]
  
  tags = {
    Name  = "${var.deployment_id}-test-app"
  }

  connection {
    host          = aws_instance.test-app.private_dns
    user          = "ubuntu"
    agent         = false
    private_key   = local.key_pair_private_key
    bastion_host  = var.bastion_public_fqdn
  }

  # provisioner "file" {
  #   source      = data.archive_file.config-bundle.output_path
  #   destination = "/var/tmp/xks-vault-config-bundle.zip"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #   ]
  # }
}