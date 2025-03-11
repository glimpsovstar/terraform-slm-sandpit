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

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"

  cluster_name                    = "${var.deployment_id}-${var.cluster_suffix}"
  cluster_version                 = var.cluster_version
  vpc_id                          = data.aws_vpc.this.id
  subnet_ids                      = data.aws_subnets.private.ids

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

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