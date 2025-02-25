module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 20.0"

  cluster_name                    = "${var.deployment_id}-platform"
  cluster_version                 = var.cluster_version
  vpc_id                          = data.aws_vpc.this.id
  subnet_ids                      = data.aws_subnets.private.ids

  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  
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

resource "aws_ec2_tag" "eks_deployment_id" {
  for_each = toset(data.aws_subnets.all.ids)

  resource_id = each.value
  key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
  value       = "shared"
}