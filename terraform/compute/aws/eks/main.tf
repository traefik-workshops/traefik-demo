module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "../vpc"

  name            = "${var.cluster_name}-vpc"
  cidr            = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id     = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  subnet_ids = var.create_vpc ? module.vpc[0].private_subnet_ids : var.private_subnet_ids

  create_cloudwatch_log_group = false

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }

  eks_managed_node_groups = length(var.worker_nodes) == 0 ? {
    default = {
      name           = "${var.cluster_name}-ng"
      ami_type       = var.cluster_node_ami_type
      instance_types = [var.cluster_node_type]
      min_size       = var.cluster_node_count
      max_size       = var.cluster_node_count
      desired_size   = var.cluster_node_count
    }
    } : {
    for wn in var.worker_nodes : wn.label => {
      name           = "${var.cluster_name}-${wn.label}"
      ami_type       = var.cluster_node_ami_type
      instance_types = [var.cluster_node_type]
      min_size       = wn.count
      max_size       = wn.count
      desired_size   = wn.count

      labels = {
        node = wn.label
      }

      taints = try(length(wn.taint), 0) > 0 ? {
        dedicated = {
          key    = "node"
          value  = wn.taint
          effect = "NO_SCHEDULE"
        }
      } : {}
    }
  }
}

module "ebs_csi_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "${module.eks.cluster_name}-ebs-csi-controller"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_policy_arns              = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "traefik_demo" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn    = module.ebs_csi_controller_role.iam_role_arn

  configuration_values = jsonencode({
    defaultStorageClass = {
      enabled = true
    }
  })

  depends_on = [module.eks]
}

resource "null_resource" "eks_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks --region "${var.cluster_location}" update-kubeconfig \
        --name "${var.cluster_name}" \
        --alias "eks-${var.cluster_name}"
      kubectl config use-context "eks-${var.cluster_name}"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }

  count      = var.update_kubeconfig ? 1 : 0
  depends_on = [aws_eks_addon.traefik_demo]
}
