module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  name               = "${var.project_name}-eks"
  kubernetes_version = var.kubernetes_version

  # Networking
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # API endpoint access
  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Authentication
  authentication_mode = "API_AND_CONFIG_MAP"

  enable_cluster_creator_admin_permissions = true

  # OIDC provider for IRSA
  enable_irsa = true

  # Kubernetes add-ons
  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Managed Node Group
  eks_managed_node_groups = {
    general = {
      name = "${var.project_name}-node-group"

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Project     = var.project_name
    Environment = "learning"
  }
}
