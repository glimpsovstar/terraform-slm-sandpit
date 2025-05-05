packer {
  required_plugins {
    amazon = {
      version = "~> 1.3.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vault_version" {
  type    = string
  default = "1.19.0"
}

data "amazon-ami" "ubuntu2404" {
  filters = {
    architecture                       = "x86_64"
    name                               = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "ubuntu2404-ami" {
  ami_description             = "An Ubuntu 24.04 AMI that is running Vault Enterprise ${var.vault_version}."
  ami_name                    = "vault-${var.vault_version}-ent-ubuntu-${formatdate("YYYYMMDDhhmm", timestamp())}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  region                      = "${var.aws_region}"
  source_ami                  = "${data.amazon-ami.ubuntu2404.id}"
  ssh_username                = "ubuntu"
  tags = {
    application     = "vault-enterprise"
    owner           = "tphan@hashicorp.com"
    packer_source   = "https://github.com/phan-t/terraform-slm-sandpint/blob/master/examples/patterns/nhi/01-vm-vault/amis/vault/ubuntu2404-vault-ent.pkr.hcl"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu2404-ami"]

  provisioner "file" {
    source      = "./scripts/install_vault_ent.sh"
    destination = "/tmp/install_vault_ent.sh"
  }

  # install vault
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_vault_ent.sh",
      "/tmp/install_vault_ent.sh ${var.vault_version}"
    ]
  }
}