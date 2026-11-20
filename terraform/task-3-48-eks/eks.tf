module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  endpoint_public_access  = true
  endpoint_private_access = true
  deletion_protection     = false

  # The Terraform user must be allowed to run kubectl.
  enable_cluster_creator_admin_permissions = true

  # This task uses a managed node group, not EKS Auto Mode.
  compute_config = {
    enabled = false
  }
  create_node_iam_role = false

  # Keep the stack to the roles the task asks for.
  # encryption_config defaults to an empty object, which still turns encryption on.
  # null turns it off so this stack does not create a KMS key.
  encryption_config           = null
  enable_irsa                 = false
  create_kms_key              = false
  enabled_log_types           = []
  create_cloudwatch_log_group = false

  # This module turns off the addons EKS used to install itself.
  # vpc-cni must exist before nodes, or they stay NotReady.
  addons = {
    vpc-cni = {
      before_compute = true
    }
    kube-proxy = {}
    coredns    = {}
  }

  iam_role_name            = "task-3-48-cluster-role"
  iam_role_use_name_prefix = false

  eks_managed_node_groups = {
    main = {
      name            = "task-3-48-node-group"
      use_name_prefix = false

      instance_types = [var.node_instance_type]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size

      subnet_ids = module.vpc.public_subnets

      # The default launch template does not assign a public IP.
      # Public subnets with MapPublicIpOnLaunch do, and there is no NAT.
      use_custom_launch_template = false

      iam_role_name              = "task-3-48-node-role"
      iam_role_use_name_prefix   = false
      iam_role_attach_cni_policy = true

      timeouts = {
        create = "40m"
        update = "40m"
        delete = "40m"
      }
    }
  }

}
