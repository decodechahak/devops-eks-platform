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

