module "app-network" {
    source = "./network"
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = "terry-test-eks-cluster"
  cluster_version = "1.22"
  vpc_id          = module.app-network.vpc_id
  subnet_ids      = module.app-network.subnet_ids

  eks_managed_node_groups = {
    default_node_group = {
      min_size     = 2
      max_size     = 2
      desired_size = 2
      instance_types = ["t3.small"]
    }
  }
}