locals {
  cluster_name = "${var.project}-cluster"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids # Phase 1: nodes in PUBLIC subnets (no NAT)

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  enable_irsa = true # for service account IAM later (Prometheus, etc.)

  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"
      # If you hit scheduling pressure later, bump to t3.small or size=2.
    }
  }

  tags = {
    Project = var.project
    Stack   = "phase-1"
  }

  # Give the cluster creator admin; handy while developing
  #enable_cluster_creator_admin_permissions = true

   access_entries = {
    terraform_deployer = {
      principal_arn = "arn:aws:iam::142021135755:role/terraform-deployer"
      policy_associations = [{
        policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = { type = "cluster" }
      }]
    }

    admin_user = {
      principal_arn = "arn:aws:iam::142021135755:user/admin-yusef"
      policy_associations = [{
        policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = { type = "cluster" }
      }]
    }
  }
}
