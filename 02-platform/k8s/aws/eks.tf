data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}*"]
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}-private*"]
  }
}

data "aws_security_group" "vault" {
  filter {
    name   = "tag:Name"
    values = ["*${var.deployment_id}-vault"]
  }
}

# Get KMS key ARN from infrastructure module
data "aws_kms_key" "vault_unseal" {
  key_id = "alias/${var.deployment_id}-vault-unseal"
}

# IAM role for Vault service account (IRSA - IAM Roles for Service Accounts)
data "aws_iam_policy_document" "vault_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:vault:vault"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "vault_kms_role" {
  name               = "${var.deployment_id}-vault-kms-role"
  assume_role_policy = data.aws_iam_policy_document.vault_assume_role_policy.json

  tags = {
    Name        = "${var.deployment_id}-vault-kms-role"
    Environment = var.deployment_id
  }
}

# Attach the KMS policy to the role
resource "aws_iam_role_policy_attachment" "vault_kms_policy" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.deployment_id}-vault-kms-unseal"
  role       = aws_iam_role.vault_kms_role.name
}

data "aws_caller_identity" "current" {}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"

  cluster_name                    = "${var.deployment_id}-${var.cluster_suffix}"
  cluster_version                 = var.cluster_version
  vpc_id                          = data.aws_vpc.this.id
  subnet_ids                      = data.aws_subnets.private.ids

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  cluster_security_group_additional_rules = {
    // allow consul to communicate with the cluster api.
    ingress_cluster_api_tcp = {
      description                = "vpc-cluster-api-https-tcp"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      cidr_blocks                = [data.aws_vpc.this.cidr_block]
    }
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  eks_managed_node_group_defaults = { 
  }

  eks_managed_node_groups = {
    "default_node_group" = {
      min_size               = 1
      max_size               = 6
      desired_size           = var.worker_desired_capacity

      instance_types         = var.worker_instance_types
      capacity_type          = var.worker_capacity_type
      key_name               = var.deployment_id
      vpc_security_group_ids = [data.aws_security_group.vault.id]

      # extend default 20 gb volume size to 50 gb
      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 50
            volume_type = "gp3"
            delete_on_termination = true
          }
        }
      ]

      # required for aws-ebs-csi-driver
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }
}

resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
  }

  depends_on = [
    module.eks
  ]
}

resource "aws_ec2_tag" "eks_cluster_name" {
  for_each = toset(data.aws_subnets.all.ids)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
  value       = "shared"
}