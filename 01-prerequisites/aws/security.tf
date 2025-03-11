module "sg-ssh" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.3.0"

  name    = "${var.deployment_id}-ssh"
  vpc_id  = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    }
  ]
}

module "sg-vault" {
  source = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.3.0"

  name        = "${var.deployment_id}-vault"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      description = "vault-api-tcp"
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    },
    {
      from_port   = 8201
      to_port     = 8201
      protocol    = "tcp"
      description = "vault-raft-tcp"
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "any-any"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}