data "aws_ami" "ubuntu2404" {

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["099720109477"]
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.ubuntu2404.id
  instance_type   = "t2.micro"
  key_name        = module.key_pair.key_pair_name
  subnet_id       = element(module.vpc.public_subnets, 1)
  security_groups = [module.sg-ssh.security_group_id]
  
  lifecycle {
    ignore_changes = all
  }

  connection {
    host          = aws_instance.bastion.public_dns
    user          = "ubuntu"
    agent         = false
    private_key   = module.key_pair.private_key_pem
  }

  provisioner "file" {
    source      = "${path.root}/${module.key_pair.key_pair_name}.pem"
    destination = "/home/ubuntu/${module.key_pair.key_pair_name}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/${module.key_pair.key_pair_name}.pem"
    ]
  }
}