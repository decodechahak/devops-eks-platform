data "aws_caller_identity" "current" {}

locals {
  name         = "eks-platform-dev"
  cluster_name = "eks-platform-dev"
}

module "vpc" {
  source        = "../../modules/vpc"
  name          = local.name
  cidr          = "10.0.0.0/16"
  azs           = ["ap-south-1a", "ap-south-1b"]
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  cluster_name  = local.cluster_name
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.35" # must be in STANDARD support, 1.33 costs 6x

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    github = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-eks-platform"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "eks-platform-app"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
}

