resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [for s in aws_subnet.private : s.id]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access = true
    # For more restrictive access, set endpoint_public_access = false and use a bastion or VPN
    public_access_cidrs = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = var.cluster_name
    Environment = "demo"
    Terraform = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy
  ]
}

# Waiter data to read the created cluster info (used to obtain OIDC issuer)
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
  depends_on = [aws_eks_cluster.this]
}

# Create TLS cert data for thumbprint
data "tls_certificate" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Create OIDC provider for IRSA
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

